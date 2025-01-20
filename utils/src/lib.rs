use std::{fmt::Display, fs::File, io::Write, time::Duration};
use csv::{ReaderBuilder, WriterBuilder};
use std::{fs, error::Error};
use serde::{Deserialize, Serialize};


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
    pub memory: String,
}

pub fn update_or_insert_record(
    file_path: &str,
    bench_arg: &str,
    duration: Option<u64>,
    proof_size: Option<u64>,
    verifier_duration: Option<u64>,
    cycle_count: Option<u64>,
    memory: Option<String>,
) -> Result<(), Box<dyn Error>> {
    let file_exists = fs::metadata(file_path).is_ok();
    let mut records = Vec::new();

    // Read existing records if file exists
    if file_exists {
        let mut rdr = ReaderBuilder::new()
            .has_headers(true)
            .from_path(file_path)?;
        for result in rdr.deserialize::<Record>() {
            let record = result?;
            records.push(record);
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
            if let Some(verifier_duration) = verifier_duration {
                record.verifier_time_ms = verifier_duration;
            }
            if let Some(cycle_count) = cycle_count {
                record.cycle_count = cycle_count;
            }
            if let Some(ref memory_str) = memory {
                record.memory = memory_str.clone();
            }
            updated = true;
            break;
        }
    }

    // If not found, append a new record
    if !updated {
        let duration = duration.unwrap_or(0);
        let proof_size = proof_size.unwrap_or(0);
        let verifier_duration = verifier_duration.unwrap_or(0);
        let cycle_count = cycle_count.unwrap_or(0);
        let memory = memory.unwrap_or(0.to_string());
        records.push(Record {
            n: bench_arg.to_string(),
            time_ms: duration,
            proof_size,
            verifier_time_ms: verifier_duration,
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

