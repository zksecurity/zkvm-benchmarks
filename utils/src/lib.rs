use std::{fmt::Display, fs::File, io::Write, time::Duration};
use csv::{ReaderBuilder, WriterBuilder};
use std::{fs, error::Error};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkConfig {
    pub n: u32,
    pub program: String,
    pub verifier_iterations: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkResult {
    pub proof_size: usize,
    #[serde(serialize_with = "serialize_duration_as_millis", rename = "duration")]
    pub prover_duration: Duration,
    #[serde(serialize_with = "serialize_durations_as_millis")]
    pub verifier_durations: Vec<Duration>,
    pub cycle_count: usize,
}

fn serialize_duration_as_millis<S>(duration: &Duration, serializer: S) -> Result<S::Ok, S::Error>
where
    S: serde::Serializer,
{
    serializer.serialize_u64(duration.as_millis() as u64)
}

fn serialize_durations_as_millis<S>(durations: &Vec<Duration>, serializer: S) -> Result<S::Ok, S::Error>
where
    S: serde::Serializer,
{
    let millis: Vec<u64> = durations.iter().map(|d| d.as_millis() as u64).collect();
    millis.serialize(serializer)
}

impl BenchmarkResult {
    pub fn to_json(&self) -> String {
        serde_json::to_string(self).unwrap()
    }
}


pub fn benchmark<T: Display + Clone>(func: fn(T) -> (Duration, usize), inputs: &[T], file: &str, input_name: &str) {
    let mut results = Vec::new();
    for input in inputs {
        let (duration, size) = func(input.clone());
        results.push((duration, size));
    }

    write_csv(file, input_name, inputs, &results);
}

pub fn write_csv<T: Display>(file: &str, input_name: &str, inputs: &[T], results: &[(Duration, usize)]) {
    let mut file = File::create(file).unwrap();
    file.write_all(format!("{},prover time (ms),proof size (bytes)\n", input_name).as_bytes()).unwrap();
    inputs.iter().zip(results).for_each(|(input, (duration, size))| {
        file.write_all(format!("{},{},{}\n", input, duration.as_millis(), size).as_bytes()).unwrap();
    });
}

pub fn size<T: Serialize>(item: &T) -> usize {
    bincode::serialized_size(item).unwrap() as usize
}

#[derive(Deserialize, Serialize, Debug)]
pub struct Record {
    pub n: String,
    #[serde(rename = "prover time(ms)")]
    pub time_ms: u64,
    #[serde(rename = "proof size(bytes)")]
    pub proof_size: u64,
    #[serde(rename = "verifier time(ms)")]
    pub verifier_time_ms: u64,
    #[serde(rename = "cycle count")]
    pub cycle_count: u64,
    #[serde(rename = "peak memory")]
    pub memory: u64,
}

pub fn update_or_insert_record(
    file_path: &str,
    bench_arg: &str,
    duration: Option<u64>,
    proof_size: Option<u64>,
    verifier_durations: Option<Vec<u64>>,
    cycle_count: Option<u64>,
    memory: Option<u64>,
) -> Result<(), Box<dyn Error>> {
    let file_exists = fs::metadata(file_path).is_ok();
    let mut records = Vec::new();

    // Read existing records if file exists
    if file_exists {
        let mut rdr = ReaderBuilder::new()
            .has_headers(true)
            .from_path(file_path)?;
        
        // Try to read as new format first, fall back to old format if needed
        let mut raw_records = Vec::new();
        for result in rdr.records() {
            raw_records.push(result?);
        }
        
        for record in raw_records {
            if let Ok(new_record) = record.deserialize::<Record>(None) {
                records.push(new_record);
            }
        }
    }

    // Check and update existing record
    let mut updated = false;
    for record in &mut records {
        if record.n == bench_arg {
            if let Some(duration) = duration {
                record.time_ms = duration;
            }
            if let Some(proof_size) = proof_size {
                record.proof_size = proof_size;
            }
            if let Some(ref verifier_durations) = verifier_durations {
                // Calculate average verifier time
                let avg_verifier_time = verifier_durations.iter().sum::<u64>() / verifier_durations.len() as u64;
                record.verifier_time_ms = avg_verifier_time;
            }
            if let Some(cycle_count) = cycle_count {
                record.cycle_count = cycle_count;
            }
            if let Some(memory_val) = memory {
                record.memory = memory_val;
            }
            updated = true;
            break;
        }
    }

    // If not found, append a new record
    if !updated {
        let duration = duration.unwrap_or(0);
        let proof_size = proof_size.unwrap_or(0);
        let cycle_count = cycle_count.unwrap_or(0);
        let memory = memory.unwrap_or(0);
        
        let verifier_time_ms = if let Some(ref verifier_durations) = verifier_durations {
            verifier_durations.iter().sum::<u64>() / verifier_durations.len() as u64
        } else {
            0
        };
        
        records.push(Record {
            n: bench_arg.to_string(),
            time_ms: duration,
            proof_size,
            verifier_time_ms,
            cycle_count,
            memory,
        });
    }

    // Write all records back
    let mut wtr = WriterBuilder::new()
        .has_headers(true)
        .from_path(file_path)?;
    for record in records {
        wtr.serialize(record)?;
    }
    wtr.flush()?;

    Ok(())
}

