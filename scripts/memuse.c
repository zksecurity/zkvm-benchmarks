#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <errno.h>

#pragma GCC diagnostic ignored "-Wformat-truncation="

#define MAX_PATH 2048
#define DEBUG 0

#define MICRO_S 1000
#define MILLI_S (MICRO_S * 1000)
#define SAMPLE_FREQ (50 * MILLI_S) // sample every 50ms

#define SLEEP (0)

// Global variables for cleanup
char our_cgroup[MAX_PATH] = {0};
pid_t cmd_pid = 0;
int output_fd = -1;

// Function to calculate time difference
unsigned long long time_diff(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) * 1000 * 1000 * 1000 + (end.tv_nsec - start.tv_nsec);
}

// Find cgroup path for a given PID
int find_cgroup_path(pid_t pid, char *path, size_t path_size) {
    char proc_path[MAX_PATH];

    // Check if the PID is in a cgroup directly
    snprintf(proc_path, sizeof(proc_path), "/proc/%d/cgroup", pid);
    int fd = open(proc_path, O_RDONLY);
    if (fd >= 0) {
        char line[MAX_PATH];
        ssize_t read_bytes;
        size_t pos = 0;

        while ((read_bytes = read(fd, line + pos, sizeof(line) - pos - 1)) > 0) {
            pos += read_bytes;
            line[pos] = '\0';

            // Process complete lines
            char *start = line;
            char *nl;
            while ((nl = strchr(start, '\n')) != NULL) {
                *nl = '\0';
                char *cgroup_path = strrchr(start, ':');
                if (cgroup_path) {
                    cgroup_path++; // Skip the colon
                    snprintf(path, path_size, "/sys/fs/cgroup%s", cgroup_path);
                    close(fd);
                    return 1;
                }
                start = nl + 1;
            }

            // Move any partial line to the beginning of the buffer
            if (start < line + pos) {
                memmove(line, start, line + pos - start);
                pos = line + pos - start;
            } else {
                pos = 0;
            }
        }
        close(fd);
    }

    return 0;
}

// cleanup function
void cleanup(int signal) {
    // kill command if still running
    if (cmd_pid > 0) {
        kill(cmd_pid, SIGTERM);
        waitpid(cmd_pid, NULL, 0);
    }

    // clean up cgroup if we created one
    if (our_cgroup[0] != '\0') {
        rmdir(our_cgroup);
    }

    if (output_fd >= 0) {
        close(output_fd);
        output_fd = -1;
    }

    exit(0);
}

unsigned long long get_memory_usage(const char *path) {
    FILE *fp = fopen(path, "r");
    if (!fp) {
        perror("fopen");
        return 0;
    }
    unsigned long long value;
    if (fscanf(fp, "%llu", &value) != 1) {
        perror("fscanf");
        fclose(fp);
        return 0;
    }
    fclose(fp);
    return value;
}

int main(int argc, char *argv[]) {
    // check if running as root
    if (geteuid() != 0) {
        fprintf(stderr, "This program requires root privileges to manage cgroups.\n");
        fprintf(stderr, "Please run with sudo: sudo %s [args]\n", argv[0]);
        return 1;
    }

    // check for correct arguments
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <OUTPUT_FILE> <COMMAND> [ARGS...]\n", argv[0]);
        return 1;
    }

    // set up signal handlers
    signal(SIGINT, cleanup);
    signal(SIGTERM, cleanup);

    // Output filename is the first argument
    const char *output_filename = argv[1];

    // Initialize output file (no header)
    output_fd = open(output_filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (output_fd < 0) {
        fprintf(stderr, "Error: Could not open output file %s\n", output_filename);
        return 1;
    }
    close(output_fd);
    output_fd = -1;

    // Try to create our own cgroup
    char cgroup_name[64];
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    snprintf(cgroup_name, sizeof(cgroup_name), "memuse_%ld%ld", ts.tv_sec, ts.tv_nsec);

    // try different possible cgroup paths
    int cgroup_created = 0;
    char *base_paths[] = {"/sys/fs/cgroup", "/sys/fs/cgroup/unified", "/sys/fs/cgroup/memory"};
    for (int i = 0; i < 3; i++) {
        if (access(base_paths[i], F_OK) == 0) {
            snprintf(our_cgroup, sizeof(our_cgroup), "%s/%s", base_paths[i], cgroup_name);
            if (mkdir(our_cgroup, 0755) == 0) {
                cgroup_created = 1;
                break;
            }
        }
    }
    if (!cgroup_created) {
        fprintf(stderr, "failed to create cgroup\n");
        exit(1);
    }

    // compute length of command string
    size_t cmd_len = 0;
    for (int i = 2; i < argc; i++) {
        cmd_len += strlen(argv[i]);
        if (i < argc - 1) {
            cmd_len += 1; // space character
        }
    }

    // concatenate command string
    char* cmd = calloc(cmd_len + 1, sizeof(char)); // +1 for null terminator
    if (cmd == NULL) {
        fprintf(stderr, "memory allocation failed\n");
        cleanup(0);
        return 1;
    }
    for (int i = 2; i < argc; i++) {
        strcat(cmd, argv[i]);
        if (i < argc - 1) {
            strcat(cmd, " ");
        }
    }


    // Active approach - we created our own cgroup
    char pid_str[16];
    snprintf(pid_str, sizeof(pid_str), "%d", getpid());

    // Place ourselves in this cgroup so any children will inherit it
    char procs_path[MAX_PATH];
    snprintf(procs_path, sizeof(procs_path), "%s/cgroup.procs", our_cgroup);
    int procs_fd = open(procs_path, O_WRONLY);
    if (procs_fd >= 0) {
        write(procs_fd, pid_str, strlen(pid_str));
        close(procs_fd);
    }

    // Set memory path - always use memory.current to catch both increases and decreases
    // memory.peak would only show the highest value and not decreases
    char mem_peak[MAX_PATH];
    char mem_current[MAX_PATH];
    snprintf(mem_current, sizeof(mem_current), "%s/memory.current", our_cgroup);
    snprintf(mem_peak, sizeof(mem_peak), "%s/memory.peak", our_cgroup);

    // Fork and exec the command
    cmd_pid = fork();
    if (cmd_pid == 0) {
        // We are running as root through sudo
        // To drop privileges, get the original user who ran sudo
        uid_t sudo_uid = 0;
        char* sudo_user = getenv("SUDO_UID");
        if (sudo_user) {
            sudo_uid = atoi(sudo_user);
        } else {
            // Fallback to real user ID if SUDO_UID is not set
            sudo_uid = getuid();
        }

        // Drop privileges to the original user
        if (setuid(sudo_uid) != 0) {
            fprintf(stderr, "failed to drop privileges: %s\n", strerror(errno));
            exit(1);
        }

        execl("/bin/sh", "sh", "-c", cmd, NULL);
        fprintf(stderr, "Failed to execute command: %s\n", cmd);
        exit(1);
    } else if (cmd_pid < 0) {
        // fork failed
        fprintf(stderr, "Failed to fork process\n");
        cleanup(0);
    }

    // open output file for monitoring
    FILE* output_fd = fopen(output_filename, "w");
    if (output_fd == NULL) {
        fprintf(stderr, "cannot open output file for monitoring\n");
        exit(1);
    }

    // check if TRACE is set in the environment
    const char *trace_env = getenv("MEM_TRACE");
    if (trace_env != NULL) {
        // open memory file for monitoring
        int mem_fd = open(mem_current, O_RDONLY);
        if (mem_fd < 0) {
            fprintf(stderr, "cannot open memory file for monitoring\n");
            exit(1);
        }

        // write the initial measurement at time 0
        struct timespec time_start;
        clock_gettime(CLOCK_REALTIME, &time_start);
        {
            char output_line[0x100];
            int len = snprintf(
                output_line,
                sizeof(output_line),
                "%llu %llu\n",
                0ull,
                get_memory_usage(mem_peak)
            );
            fwrite(output_line, len, 1, output_fd);
        }

        // sample number (we just collected one)
        unsigned long long sample = 1;
        while (1) {
            // check if command is still running
            int status;
            pid_t result = waitpid(cmd_pid, &status, WNOHANG);
            if (result != 0) break;

            // probe aggressively
            struct timespec time_now;
            unsigned long long max_mem = 0;
            unsigned long long next_sample_time = sample * SAMPLE_FREQ;
            while (1) {
                // check if it's been long enough since last sample
                clock_gettime(CLOCK_REALTIME, &time_now);
                if (time_diff(time_start, time_now) > next_sample_time) {
                    break;
                }

                // get memory value
                char mem_val_str[32] = {0};
                ssize_t bytes_read = read(mem_fd, mem_val_str, sizeof(mem_val_str) - 1);

                if (bytes_read == 0) {
                    fprintf(stderr, "Error reading from memory file\n");
                    exit(1);
                }

                // zero-terminate string
                mem_val_str[bytes_read] = '\0';
                char *nl = strchr(mem_val_str, '\n');
                if (nl) *nl = '\0';

                // parse and take max
                unsigned long mem_val = strtoul(mem_val_str, NULL, 10);
                if (mem_val > max_mem) {
                    max_mem = mem_val;
                }

                // seek to the start
                lseek(mem_fd, 0, SEEK_SET);

                // wait for next probe?
                if (SLEEP > 0) {
                    usleep(SLEEP);
                }
            }

            // write to output file
            char output_line[0x100];
            unsigned long long elapsed = time_diff(time_start, time_now);
            int len = snprintf(output_line, sizeof(output_line), "%llu %llu\n", elapsed / MICRO_S, max_mem);
            fwrite(output_line, len, 1, output_fd);
            sample++;
        }

        close(mem_fd);
    }


    // Wait for the command to finish
    int status;
    waitpid(cmd_pid, &status, 0);

    // final "PEAK" usage measurement
    // write to output file
    {
       char output_line[0x100];
       int len = snprintf(
           output_line,
           sizeof(output_line),
           "PEAK %llu\n",
           get_memory_usage(mem_peak)
       );
       fwrite(output_line, len, 1, output_fd);
    }

    // flush measurements to output file
    fflush(output_fd);
    fclose(output_fd);
    free(cmd);
    cleanup(0);
}
