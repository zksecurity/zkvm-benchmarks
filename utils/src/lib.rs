use std::time::Duration;

use serde::{Deserialize, Serialize};

pub mod memory;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum VM {
    Jolt,
    SP1,
    Risc0,
    Stone,
    Stwo,
    OpenVM,
}

impl std::fmt::Display for VM {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            VM::Jolt => write!(f, "jolt"),
            VM::SP1 => write!(f, "sp1"),
            VM::Risc0 => write!(f, "risc0"),
            VM::Stone => write!(f, "stone"),
            VM::Stwo => write!(f, "stwo"),
            VM::OpenVM => write!(f, "openvm"),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkConfig {
    pub n: u32,
    pub program: String,
    pub verifier_iterations: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq, Eq)]
pub struct BenchmarkResult {
    #[serde(rename = "proof_size_bytes")]
    pub proof_size: usize,
    #[serde(
        serialize_with = "serialize_durations_as_millis",
        deserialize_with = "deserialize_durations_from_millis",
        rename = "prover_durations_ms"
    )]
    pub prover_durations: Vec<Duration>,
    #[serde(
        serialize_with = "serialize_durations_as_millis",
        deserialize_with = "deserialize_durations_from_millis",
        rename = "verifier_durations_ms"
    )]
    pub verifier_durations: Vec<Duration>,
    pub cycle_count: usize,
    #[serde(rename = "peak_memory_bytes", skip_serializing_if = "Option::is_none")]
    pub peak_memory: Option<u64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkName {
    pub vm: VM,
    pub program: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkId {
    #[serde(flatten)]
    pub name: BenchmarkName,
    pub n: u32,
}

impl std::fmt::Display for BenchmarkName {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}-{}", self.vm, self.program)
    }
}

impl std::fmt::Display for BenchmarkId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}-n{}", self.name, self.n)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum BenchmarkStatus {
    Success(BenchmarkResult),
    Failure { status: i32 },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchmarkConfigAndResult {
    // input to the benchmark run
    pub config: BenchmarkConfig,
    // output of the benchmark run
    pub result: BenchmarkStatus,
}

impl BenchmarkConfigAndResult {
    pub fn to_json(&self) -> String {
        serde_json::to_string_pretty(self).unwrap()
    }
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

fn deserialize_durations_from_millis<'de, D>(deserializer: D) -> Result<Vec<Duration>, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let millis: Vec<u64> = Vec::deserialize(deserializer)?;
    Ok(millis.into_iter().map(Duration::from_millis).collect())
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
            "risc0" => Ok(VM::Risc0),
            "stone" => Ok(VM::Stone),
            "stwo" => Ok(VM::Stwo),
            "openvm" => Ok(VM::OpenVM),
            _ => Err(format!("Unknown VM: {}", vm_name)),
        }
    }
}

impl BenchmarkName {
    pub fn parse(benchmark_name: &str) -> Result<BenchmarkName, String> {
        let parts: Vec<&str> = benchmark_name.splitn(2, '-').collect();
        if parts.len() != 2 {
            return Err(format!(
                "Invalid benchmark name format: {}. Expected format: vm-program",
                benchmark_name
            ));
        }
        Ok(BenchmarkName {
            vm: VM::parse(parts[0])?,
            program: parts[1].to_string(),
        })
    }
}

pub fn size<T: Serialize>(item: &T) -> usize {
    bincode::serialized_size(item).unwrap() as usize
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_benchmark_result_json_roundtrip() {
        // Create a sample BenchmarkResult with various durations
        let original = BenchmarkResult {
            proof_size: 12345,
            prover_durations: vec![
                Duration::from_millis(178689),
                Duration::from_millis(200000),
                Duration::from_millis(150000),
            ],
            verifier_durations: vec![Duration::from_millis(1234), Duration::from_millis(5678)],
            cycle_count: 987654,
            peak_memory: Some(1073741824), // 1GB
        };

        // Serialize to JSON
        let json = original.to_json();

        // Verify the JSON contains milliseconds (not Duration objects)
        assert!(json.contains("\"prover_durations_ms\": ["));
        assert!(json.contains("178689"));
        assert!(json.contains("\"verifier_durations_ms\": ["));
        assert!(json.contains("1234"));

        // Deserialize from JSON
        let deserialized: BenchmarkResult =
            serde_json::from_str(&json).expect("Failed to deserialize BenchmarkResult from JSON");

        // Verify the original and deserialized results are identical
        assert_eq!(original, deserialized);
    }

    #[test]
    fn test_benchmark_result_json_format() {
        let result = BenchmarkResult {
            proof_size: 1000,
            prover_durations: vec![Duration::from_millis(500)],
            verifier_durations: vec![Duration::from_millis(50)],
            cycle_count: 10000,
            peak_memory: None,
        };

        let json = result.to_json();
        let parsed: serde_json::Value = serde_json::from_str(&json).unwrap();

        // Verify field names are correct
        assert!(parsed.get("proof_size_bytes").is_some());
        assert!(parsed.get("prover_durations_ms").is_some());
        assert!(parsed.get("verifier_durations_ms").is_some());
        assert!(parsed.get("cycle_count").is_some());

        // Verify peak_memory is not included when None
        assert!(parsed.get("peak_memory_bytes").is_none());

        // Verify durations are arrays of numbers
        assert_eq!(parsed["prover_durations_ms"][0], 500);
        assert_eq!(parsed["verifier_durations_ms"][0], 50);
    }

    #[test]
    fn test_benchmark_result_equality() {
        let result1 = BenchmarkResult {
            proof_size: 1000,
            prover_durations: vec![Duration::from_millis(500), Duration::from_millis(1000)],
            verifier_durations: vec![Duration::from_millis(50)],
            cycle_count: 10000,
            peak_memory: Some(1234567),
        };

        let result2 = BenchmarkResult {
            proof_size: 1000,
            prover_durations: vec![Duration::from_millis(500), Duration::from_millis(1000)],
            verifier_durations: vec![Duration::from_millis(50)],
            cycle_count: 10000,
            peak_memory: Some(1234567),
        };

        let result3 = BenchmarkResult {
            proof_size: 1000,
            prover_durations: vec![Duration::from_millis(500), Duration::from_millis(999)], /* Different duration */
            verifier_durations: vec![Duration::from_millis(50)],
            cycle_count: 10000,
            peak_memory: Some(1234567),
        };

        assert_eq!(result1, result2);
        assert_ne!(result1, result3);
    }
}
