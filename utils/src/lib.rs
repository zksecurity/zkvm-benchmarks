use serde::{Deserialize, Serialize};
use std::time::Duration;

pub mod memory;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum VM {
    Jolt,
    SP1,
    RiscZero,
    Stone,
    Stwo,
    OpenVM,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkConfig {
    pub n: u32,
    pub program: String,
    pub verifier_iterations: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkResult {
    #[serde(rename = "proof_size_bytes")]
    pub proof_size: usize,
    #[serde(
        serialize_with = "serialize_durations_as_millis",
        rename = "prover_durations_ms"
    )]
    pub prover_durations: Vec<Duration>,
    #[serde(
        serialize_with = "serialize_durations_as_millis",
        rename = "verifier_durations_ms"
    )]
    pub verifier_durations: Vec<Duration>,
    pub cycle_count: usize,
    #[serde(rename = "peak_memory_bytes", skip_serializing_if = "Option::is_none")]
    pub peak_memory: Option<u64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkId {
    pub vm: VM,
    pub program: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkMetadata {
    #[serde(flatten)]
    pub id: BenchmarkId,
    pub benchmark_name: String,
    pub config: BenchmarkConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkResultWithMetadata {
    #[serde(flatten)]
    pub metadata: BenchmarkMetadata,
    #[serde(flatten)]
    pub result: BenchmarkResult,
}

fn serialize_durations_as_millis<S>(
    durations: &Vec<Duration>,
    serializer: S,
) -> Result<S::Ok, S::Error>
where
    S: serde::Serializer,
{
    let millis: Vec<u64> = durations.iter().map(|d| d.as_millis() as u64).collect();
    millis.serialize(serializer)
}

impl BenchmarkResult {
    pub fn to_json(&self) -> String {
        serde_json::to_string_pretty(self).unwrap()
    }
}

impl VM {
    pub fn parse(vm_name: &str) -> Result<VM, String> {
        match vm_name {
            "jolt" => Ok(VM::Jolt),
            "sp1" => Ok(VM::SP1),
            "risczero" => Ok(VM::RiscZero),
            "stone" => Ok(VM::Stone),
            "stwo" => Ok(VM::Stwo),
            "openvm" => Ok(VM::OpenVM),
            _ => Err(format!("Unknown VM: {}", vm_name)),
        }
    }
}

impl BenchmarkId {
    pub fn parse(benchmark_name: &str) -> Result<BenchmarkId, String> {
        let parts: Vec<&str> = benchmark_name.splitn(2, '-').collect();
        if parts.len() != 2 {
            return Err(format!(
                "Invalid benchmark name format: {}. Expected format: vm-program",
                benchmark_name
            ));
        }
        Ok(BenchmarkId {
            vm: VM::parse(parts[0])?,
            program: parts[1].to_string(),
        })
    }
}


pub fn size<T: Serialize>(item: &T) -> usize {
    bincode::serialized_size(item).unwrap() as usize
}

