import Foundation
import SwiftUI

// MARK: - Retell AI Models
struct RetellCallRequest: Codable {
    let from_number: String
    let to_number: String
    let override_agent_id: String?
    let override_agent_version: Int?
    let metadata: [String: Any]?
    let retell_llm_dynamic_variables: [String: String]?
    let custom_sip_headers: [String: String]?
    
    init(fromNumber: String, toNumber: String, overrideAgentId: String? = nil, overrideAgentVersion: Int? = nil, metadata: [String: Any]? = nil, retellLlmDynamicVariables: [String: String]? = nil, customSipHeaders: [String: String]? = nil) {
        self.from_number = fromNumber
        self.to_number = toNumber
        self.override_agent_id = overrideAgentId
        self.override_agent_version = overrideAgentVersion
        self.metadata = metadata
        self.retell_llm_dynamic_variables = retellLlmDynamicVariables
        self.custom_sip_headers = customSipHeaders
    }
    
    // Custom encoding to handle [String: Any] for metadata
    enum CodingKeys: String, CodingKey {
        case from_number, to_number, override_agent_id, override_agent_version, metadata, retell_llm_dynamic_variables, custom_sip_headers
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(from_number, forKey: .from_number)
        try container.encode(to_number, forKey: .to_number)
        try container.encodeIfPresent(override_agent_id, forKey: .override_agent_id)
        try container.encodeIfPresent(override_agent_version, forKey: .override_agent_version)
        try container.encodeIfPresent(retell_llm_dynamic_variables, forKey: .retell_llm_dynamic_variables)
        try container.encodeIfPresent(custom_sip_headers, forKey: .custom_sip_headers)
        
        // Handle metadata encoding
        if let metadata = metadata {
            var metadataContainer = container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .metadata)
            for (key, value) in metadata {
                let codingKey = DynamicCodingKey(stringValue: key)!
                if let stringValue = value as? String {
                    try metadataContainer.encode(stringValue, forKey: codingKey)
                } else if let intValue = value as? Int {
                    try metadataContainer.encode(intValue, forKey: codingKey)
                } else if let boolValue = value as? Bool {
                    try metadataContainer.encode(boolValue, forKey: codingKey)
                }
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        from_number = try container.decode(String.self, forKey: .from_number)
        to_number = try container.decode(String.self, forKey: .to_number)
        override_agent_id = try container.decodeIfPresent(String.self, forKey: .override_agent_id)
        override_agent_version = try container.decodeIfPresent(Int.self, forKey: .override_agent_version)
        retell_llm_dynamic_variables = try container.decodeIfPresent([String: String].self, forKey: .retell_llm_dynamic_variables)
        custom_sip_headers = try container.decodeIfPresent([String: String].self, forKey: .custom_sip_headers)
        
        // Handle metadata decoding
        if let metadataContainer = try? container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .metadata) {
            var metadataDict: [String: Any] = [:]
            for key in metadataContainer.allKeys {
                if let stringValue = try? metadataContainer.decode(String.self, forKey: key) {
                    metadataDict[key.stringValue] = stringValue
                } else if let intValue = try? metadataContainer.decode(Int.self, forKey: key) {
                    metadataDict[key.stringValue] = intValue
                } else if let boolValue = try? metadataContainer.decode(Bool.self, forKey: key) {
                    metadataDict[key.stringValue] = boolValue
                }
            }
            metadata = metadataDict.isEmpty ? nil : metadataDict
        } else {
            metadata = nil
        }
    }
}

// Helper for dynamic coding keys
struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        return nil
    }
}

struct RetellCallResponse: Codable {
    let call_type: String
    let from_number: String
    let to_number: String
    let direction: String
    let telephony_identifier: TelephonyIdentifier?
    let call_id: String
    let agent_id: String
    let agent_version: Int
    let call_status: String
    let metadata: [String: Any]?
    let retell_llm_dynamic_variables: [String: String]?
    let collected_dynamic_variables: [String: String]?
    let custom_sip_headers: [String: String]?
    let data_storage_setting: String?
    let opt_in_signed_url: Bool?
    let start_timestamp: Int?
    let end_timestamp: Int?
    let duration_ms: Int?
    let transcript: String?
    let transcript_object: [Utterance]?
    let transcript_with_tool_calls: [UtteranceOrToolCall]?
    let scrubbed_transcript_with_tool_calls: [UtteranceOrToolCall]?
    let recording_url: String?
    let recording_multi_channel_url: String?
    let scrubbed_recording_url: String?
    let scrubbed_recording_multi_channel_url: String?
    let public_log_url: String?
    let knowledge_base_retrieved_contents_url: String?
    let latency: CallLatency?
    let disconnection_reason: String?
    let call_analysis: CallAnalysis?
    let call_cost: CallCost?
    let llm_token_usage: LLMTokenUsage?
    
    // Custom decoding to handle [String: Any] for metadata
    enum CodingKeys: String, CodingKey {
        case call_type, from_number, to_number, direction, telephony_identifier, call_id, agent_id, agent_version, call_status, metadata, retell_llm_dynamic_variables, collected_dynamic_variables, custom_sip_headers, data_storage_setting, opt_in_signed_url, start_timestamp, end_timestamp, duration_ms, transcript, transcript_object, transcript_with_tool_calls, scrubbed_transcript_with_tool_calls, recording_url, recording_multi_channel_url, scrubbed_recording_url, scrubbed_recording_multi_channel_url, public_log_url, knowledge_base_retrieved_contents_url, latency, disconnection_reason, call_analysis, call_cost, llm_token_usage
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(call_type, forKey: .call_type)
        try container.encode(from_number, forKey: .from_number)
        try container.encode(to_number, forKey: .to_number)
        try container.encode(direction, forKey: .direction)
        try container.encodeIfPresent(telephony_identifier, forKey: .telephony_identifier)
        try container.encode(call_id, forKey: .call_id)
        try container.encode(agent_id, forKey: .agent_id)
        try container.encode(agent_version, forKey: .agent_version)
        try container.encode(call_status, forKey: .call_status)
        try container.encodeIfPresent(retell_llm_dynamic_variables, forKey: .retell_llm_dynamic_variables)
        try container.encodeIfPresent(collected_dynamic_variables, forKey: .collected_dynamic_variables)
        try container.encodeIfPresent(custom_sip_headers, forKey: .custom_sip_headers)
        try container.encodeIfPresent(data_storage_setting, forKey: .data_storage_setting)
        try container.encodeIfPresent(opt_in_signed_url, forKey: .opt_in_signed_url)
        try container.encodeIfPresent(start_timestamp, forKey: .start_timestamp)
        try container.encodeIfPresent(end_timestamp, forKey: .end_timestamp)
        try container.encodeIfPresent(duration_ms, forKey: .duration_ms)
        try container.encodeIfPresent(transcript, forKey: .transcript)
        try container.encodeIfPresent(transcript_object, forKey: .transcript_object)
        try container.encodeIfPresent(transcript_with_tool_calls, forKey: .transcript_with_tool_calls)
        try container.encodeIfPresent(scrubbed_transcript_with_tool_calls, forKey: .scrubbed_transcript_with_tool_calls)
        try container.encodeIfPresent(recording_url, forKey: .recording_url)
        try container.encodeIfPresent(recording_multi_channel_url, forKey: .recording_multi_channel_url)
        try container.encodeIfPresent(scrubbed_recording_url, forKey: .scrubbed_recording_url)
        try container.encodeIfPresent(scrubbed_recording_multi_channel_url, forKey: .scrubbed_recording_multi_channel_url)
        try container.encodeIfPresent(public_log_url, forKey: .public_log_url)
        try container.encodeIfPresent(knowledge_base_retrieved_contents_url, forKey: .knowledge_base_retrieved_contents_url)
        try container.encodeIfPresent(latency, forKey: .latency)
        try container.encodeIfPresent(disconnection_reason, forKey: .disconnection_reason)
        try container.encodeIfPresent(call_analysis, forKey: .call_analysis)
        try container.encodeIfPresent(call_cost, forKey: .call_cost)
        try container.encodeIfPresent(llm_token_usage, forKey: .llm_token_usage)
        
        // Handle metadata encoding
        if let metadata = metadata {
            var metadataContainer = container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .metadata)
            for (key, value) in metadata {
                let codingKey = DynamicCodingKey(stringValue: key)!
                if let stringValue = value as? String {
                    try metadataContainer.encode(stringValue, forKey: codingKey)
                } else if let intValue = value as? Int {
                    try metadataContainer.encode(intValue, forKey: codingKey)
                } else if let boolValue = value as? Bool {
                    try metadataContainer.encode(boolValue, forKey: codingKey)
                }
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        call_type = try container.decode(String.self, forKey: .call_type)
        from_number = try container.decode(String.self, forKey: .from_number)
        to_number = try container.decode(String.self, forKey: .to_number)
        direction = try container.decode(String.self, forKey: .direction)
        telephony_identifier = try container.decodeIfPresent(TelephonyIdentifier.self, forKey: .telephony_identifier)
        call_id = try container.decode(String.self, forKey: .call_id)
        agent_id = try container.decode(String.self, forKey: .agent_id)
        agent_version = try container.decode(Int.self, forKey: .agent_version)
        call_status = try container.decode(String.self, forKey: .call_status)
        retell_llm_dynamic_variables = try container.decodeIfPresent([String: String].self, forKey: .retell_llm_dynamic_variables)
        collected_dynamic_variables = try container.decodeIfPresent([String: String].self, forKey: .collected_dynamic_variables)
        custom_sip_headers = try container.decodeIfPresent([String: String].self, forKey: .custom_sip_headers)
        data_storage_setting = try container.decodeIfPresent(String.self, forKey: .data_storage_setting)
        opt_in_signed_url = try container.decodeIfPresent(Bool.self, forKey: .opt_in_signed_url)
        start_timestamp = try container.decodeIfPresent(Int.self, forKey: .start_timestamp)
        end_timestamp = try container.decodeIfPresent(Int.self, forKey: .end_timestamp)
        duration_ms = try container.decodeIfPresent(Int.self, forKey: .duration_ms)
        transcript = try container.decodeIfPresent(String.self, forKey: .transcript)
        transcript_object = try container.decodeIfPresent([Utterance].self, forKey: .transcript_object)
        transcript_with_tool_calls = try container.decodeIfPresent([UtteranceOrToolCall].self, forKey: .transcript_with_tool_calls)
        scrubbed_transcript_with_tool_calls = try container.decodeIfPresent([UtteranceOrToolCall].self, forKey: .scrubbed_transcript_with_tool_calls)
        recording_url = try container.decodeIfPresent(String.self, forKey: .recording_url)
        recording_multi_channel_url = try container.decodeIfPresent(String.self, forKey: .recording_multi_channel_url)
        scrubbed_recording_url = try container.decodeIfPresent(String.self, forKey: .scrubbed_recording_url)
        scrubbed_recording_multi_channel_url = try container.decodeIfPresent(String.self, forKey: .scrubbed_recording_multi_channel_url)
        public_log_url = try container.decodeIfPresent(String.self, forKey: .public_log_url)
        knowledge_base_retrieved_contents_url = try container.decodeIfPresent(String.self, forKey: .knowledge_base_retrieved_contents_url)
        latency = try container.decodeIfPresent(CallLatency.self, forKey: .latency)
        disconnection_reason = try container.decodeIfPresent(String.self, forKey: .disconnection_reason)
        call_analysis = try container.decodeIfPresent(CallAnalysis.self, forKey: .call_analysis)
        call_cost = try container.decodeIfPresent(CallCost.self, forKey: .call_cost)
        llm_token_usage = try container.decodeIfPresent(LLMTokenUsage.self, forKey: .llm_token_usage)
        
        // Handle metadata decoding
        if let metadataContainer = try? container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .metadata) {
            var metadataDict: [String: Any] = [:]
            for key in metadataContainer.allKeys {
                if let stringValue = try? metadataContainer.decode(String.self, forKey: key) {
                    metadataDict[key.stringValue] = stringValue
                } else if let intValue = try? metadataContainer.decode(Int.self, forKey: key) {
                    metadataDict[key.stringValue] = intValue
                } else if let boolValue = try? metadataContainer.decode(Bool.self, forKey: key) {
                    metadataDict[key.stringValue] = boolValue
                }
            }
            metadata = metadataDict.isEmpty ? nil : metadataDict
        } else {
            metadata = nil
        }
    }
}

// MARK: - Supporting Data Structures
struct TelephonyIdentifier: Codable {
    let twilio_call_sid: String?
}

struct Word: Codable {
    let word: String
    let start: Double
    let end: Double
}

struct Utterance: Codable {
    let role: String
    let content: String
    let words: [Word]
}

enum UtteranceOrToolCall: Codable {
    case utterance(Utterance)
    case toolCallInvocation(ToolCallInvocationUtterance)
    case toolCallResult(ToolCallResultUtterance)
    case dtmf(DTMFUtterance)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Try to decode as different types
        if let utterance = try? container.decode(Utterance.self) {
            self = .utterance(utterance)
        } else if let toolInvocation = try? container.decode(ToolCallInvocationUtterance.self) {
            self = .toolCallInvocation(toolInvocation)
        } else if let toolResult = try? container.decode(ToolCallResultUtterance.self) {
            self = .toolCallResult(toolResult)
        } else if let dtmf = try? container.decode(DTMFUtterance.self) {
            self = .dtmf(dtmf)
        } else {
            throw DecodingError.typeMismatch(UtteranceOrToolCall.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode UtteranceOrToolCall"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .utterance(let utterance):
            try container.encode(utterance)
        case .toolCallInvocation(let toolInvocation):
            try container.encode(toolInvocation)
        case .toolCallResult(let toolResult):
            try container.encode(toolResult)
        case .dtmf(let dtmf):
            try container.encode(dtmf)
        }
    }
}

struct ToolCallInvocationUtterance: Codable {
    let role: String
    let tool_call_id: String
    let name: String
    let arguments: String
}

struct ToolCallResultUtterance: Codable {
    let role: String
    let tool_call_id: String
    let content: String
}

struct DTMFUtterance: Codable {
    let role: String
    let digit: String
}

struct CallLatency: Codable {
    let e2e: LatencyMetrics?
    let llm: LatencyMetrics?
    let llm_websocket_network_rtt: LatencyMetrics?
    let tts: LatencyMetrics?
    let knowledge_base: LatencyMetrics?
    let s2s: LatencyMetrics?
}

struct LatencyMetrics: Codable {
    let p50: Double?
    let p90: Double?
    let p95: Double?
    let p99: Double?
    let max: Double?
    let min: Double?
    let num: Int?
    let values: [Double]?
}

struct CallAnalysis: Codable {
    let call_summary: String?
    let in_voicemail: Bool?
    let user_sentiment: String?
    let call_successful: Bool?
    let custom_analysis_data: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case call_summary, in_voicemail, user_sentiment, call_successful, custom_analysis_data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        call_summary = try container.decodeIfPresent(String.self, forKey: .call_summary)
        in_voicemail = try container.decodeIfPresent(Bool.self, forKey: .in_voicemail)
        user_sentiment = try container.decodeIfPresent(String.self, forKey: .user_sentiment)
        call_successful = try container.decodeIfPresent(Bool.self, forKey: .call_successful)
        
        // Handle custom_analysis_data decoding
        if let customDataContainer = try? container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .custom_analysis_data) {
            var customDataDict: [String: Any] = [:]
            for key in customDataContainer.allKeys {
                if let stringValue = try? customDataContainer.decode(String.self, forKey: key) {
                    customDataDict[key.stringValue] = stringValue
                } else if let intValue = try? customDataContainer.decode(Int.self, forKey: key) {
                    customDataDict[key.stringValue] = intValue
                } else if let boolValue = try? customDataContainer.decode(Bool.self, forKey: key) {
                    customDataDict[key.stringValue] = boolValue
                }
            }
            custom_analysis_data = customDataDict.isEmpty ? nil : customDataDict
        } else {
            custom_analysis_data = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(call_summary, forKey: .call_summary)
        try container.encodeIfPresent(in_voicemail, forKey: .in_voicemail)
        try container.encodeIfPresent(user_sentiment, forKey: .user_sentiment)
        try container.encodeIfPresent(call_successful, forKey: .call_successful)
        
        // Handle custom_analysis_data encoding
        if let customData = custom_analysis_data {
            var customDataContainer = container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .custom_analysis_data)
            for (key, value) in customData {
                let codingKey = DynamicCodingKey(stringValue: key)!
                if let stringValue = value as? String {
                    try customDataContainer.encode(stringValue, forKey: codingKey)
                } else if let intValue = value as? Int {
                    try customDataContainer.encode(intValue, forKey: codingKey)
                } else if let boolValue = value as? Bool {
                    try customDataContainer.encode(boolValue, forKey: codingKey)
                }
            }
        }
    }
}

struct CallCost: Codable {
    let product_costs: [ProductCost]
    let total_duration_seconds: Double
    let total_duration_unit_price: Double
    let combined_cost: Double
}

struct ProductCost: Codable {
    let product: String
    let unit_price: Double
    let cost: Double
}

struct LLMTokenUsage: Codable {
    let values: [Double]
    let average: Double
    let num_requests: Double
}

// MARK: - Retell AI Service
class RetellAIService: ObservableObject {
    @Published var isCreatingCall = false
    @Published var isFetchingTranscription = false
    @Published var lastCallId: String?
    @Published var lastTranscription: String?
    @Published var errorMessage: String = ""
    @Published var callStatus: String = ""
    @Published var phishingAnalysis = ""
    @Published var isAnalyzingTranscript = false
    
    private let apiKey: String
    private let baseURL = "https://api.retellai.com"
    private let geminiService: GeminiAPIService
    
    // Hardcoded phone numbers for phishing simulation
    private let hardcodedFromNumber = "+18445540433"
    private let hardcodedToNumber = "+14125897599"
    
    /// Test API connectivity and authentication
    func testAPIConnectivity() async -> Bool {
        NSLog("🔴 RetellAI: Testing API connectivity...")
        
        // Try a simple GET request to test authentication
        guard let url = URL(string: "\(baseURL)/agents") else {
            NSLog("❌ RetellAI: Invalid URL for testing")
            return false
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                NSLog("❌ RetellAI: Invalid response type during test")
                return false
            }
            
            NSLog("🔴 RetellAI: Test response status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                NSLog("✅ RetellAI: API connectivity test successful")
                return true
            } else if httpResponse.statusCode == 401 {
                NSLog("❌ RetellAI: Authentication failed - check API key")
                return false
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "No response"
                NSLog("❌ RetellAI: Test failed with status \(httpResponse.statusCode): \(responseString)")
                return false
            }
        } catch {
            NSLog("❌ RetellAI: Network error during test: \(error)")
            return false
        }
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
        self.geminiService = GeminiAPIService(apiKey: GeminiConfig.shared.apiKey)
    }
    
    // MARK: - Public Methods
    
    /// Create an outbound call using Retell AI API (uses hardcoded phone numbers)
    func createOutboundCall() async -> Bool {
        NSLog("🔴 RetellAI: Starting outbound call creation...")
        NSLog("🔴 RetellAI: Using hardcoded numbers - From: \(hardcodedFromNumber), To: \(hardcodedToNumber)")
        
        await MainActor.run {
            isCreatingCall = true
            errorMessage = ""
            lastCallId = nil
        }
        
        do {
            let response = try await makeCreateCallRequest(fromNumber: hardcodedFromNumber, toNumber: hardcodedToNumber)
            
            await MainActor.run {
                isCreatingCall = false
                lastCallId = response.call_id
                callStatus = response.call_status
                NSLog("✅ RetellAI: Call created successfully with ID: \(response.call_id)")
            }
            
            return true
        } catch {
            await MainActor.run {
                isCreatingCall = false
                errorMessage = error.localizedDescription
                NSLog("❌ RetellAI: Failed to create call: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    /// Get call transcription and details
    func getCallTranscription(callId: String) async -> Bool {
        NSLog("🔴 RetellAI: Fetching transcription for call ID: \(callId)")
        
        await MainActor.run {
            isFetchingTranscription = true
            errorMessage = ""
        }
        
        do {
            let response = try await makeGetCallRequest(callId: callId)
            
            await MainActor.run {
                isFetchingTranscription = false
                lastTranscription = response.transcript
                callStatus = response.call_status
                
                // Log the transcription using NSLog - 4 times as requested
                if let transcript = response.transcript, !transcript.isEmpty {
                    // First log
                    NSLog("🔴 PHISHING CALL TRANSCRIPTION (LOG 1/4):")
                    NSLog("🔴 =================================")
                    NSLog("🔴 Call ID: \(callId)")
                    NSLog("🔴 Status: \(response.call_status)")
                    NSLog("🔴 From: \(response.from_number)")
                    NSLog("🔴 To: \(response.to_number)")
                    NSLog("🔴 Transcript:")
                    NSLog("🔴 \(transcript)")
                    NSLog("🔴 =================================")
                    
                    // Second log
                    NSLog("🔴 PHISHING CALL TRANSCRIPTION (LOG 2/4):")
                    NSLog("🔴 =================================")
                    NSLog("🔴 Call ID: \(callId)")
                    NSLog("🔴 Status: \(response.call_status)")
                    NSLog("🔴 From: \(response.from_number)")
                    NSLog("🔴 To: \(response.to_number)")
                    NSLog("🔴 Transcript:")
                    NSLog("🔴 \(transcript)")
                    NSLog("🔴 =================================")
                    
                    // Third log
                    NSLog("🔴 PHISHING CALL TRANSCRIPTION (LOG 3/4):")
                    NSLog("🔴 =================================")
                    NSLog("🔴 Call ID: \(callId)")
                    NSLog("🔴 Status: \(response.call_status)")
                    NSLog("🔴 From: \(response.from_number)")
                    NSLog("🔴 To: \(response.to_number)")
                    NSLog("🔴 Transcript:")
                    NSLog("🔴 \(transcript)")
                    NSLog("🔴 =================================")
                    
                    // Fourth log
                    NSLog("🔴 PHISHING CALL TRANSCRIPTION (LOG 4/4):")
                    NSLog("🔴 =================================")
                    NSLog("🔴 Call ID: \(callId)")
                    NSLog("🔴 Status: \(response.call_status)")
                    NSLog("🔴 From: \(response.from_number)")
                    NSLog("🔴 To: \(response.to_number)")
                    NSLog("🔴 Transcript:")
                    NSLog("🔴 \(transcript)")
                    NSLog("🔴 =================================")
                    
                    // Also log call summary if available
                    if let analysis = response.call_analysis, let summary = analysis.call_summary {
                        NSLog("🔴 Call Summary: \(summary)")
                    }
                    
                    // Log analysis if available
                    if let analysis = response.call_analysis {
                        NSLog("🔴 Call Analysis:")
                        if let sentiment = analysis.user_sentiment {
                            NSLog("🔴 User Sentiment: \(sentiment)")
                        }
                        if let callSuccessful = analysis.call_successful {
                            NSLog("🔴 Call Successful: \(callSuccessful)")
                        }
                        if let inVoicemail = analysis.in_voicemail {
                            NSLog("🔴 In Voicemail: \(inVoicemail)")
                        }
                    }
                } else {
                    NSLog("🔴 No transcription available for call ID: \(callId)")
                }
            }
            
            // Analyze the transcription with Gemini if we have one
            if let transcript = response.transcript, !transcript.isEmpty {
                await analyzePhishingTranscript(transcript: transcript)
            }
            
            return true
        } catch {
            await MainActor.run {
                isFetchingTranscription = false
                errorMessage = error.localizedDescription
                NSLog("❌ RetellAI: Failed to fetch transcription: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    /// Complete phishing call simulation - creates call and waits for completion
    func simulatePhishingCall() async {
        NSLog("🔴 PHISHING SIMULATION: Starting phishing call simulation...")
        NSLog("🔴 PHISHING SIMULATION: Using hardcoded numbers - From: \(hardcodedFromNumber), To: \(hardcodedToNumber)")
        
        // Step 1: Create the call
        let callCreated = await createOutboundCall()
        
        if !callCreated {
            NSLog("❌ PHISHING SIMULATION: Failed to create call")
            return
        }
        
        guard let callId = lastCallId else {
            NSLog("❌ PHISHING SIMULATION: No call ID received")
            return
        }
        
        NSLog("🔴 PHISHING SIMULATION: Call created with ID: \(callId)")
        NSLog("🔴 PHISHING SIMULATION: Waiting for call completion...")
        
        // Step 2: Poll for call completion and transcription
        // We'll poll every 5 seconds for up to 5 minutes
        let maxAttempts = 60 // 5 minutes with 5-second intervals
        var attempts = 0
        
        while attempts < maxAttempts {
            // Wait 5 seconds before checking
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            attempts += 1
            
            NSLog("🔴 PHISHING SIMULATION: Checking call status (attempt \(attempts)/\(maxAttempts))")
            
            let transcriptionFetched = await getCallTranscription(callId: callId)
            
            if transcriptionFetched && !(lastTranscription?.isEmpty ?? true) {
                NSLog("✅ PHISHING SIMULATION: Transcription received successfully!")
                return
            }
            
            // If call status indicates completion but no transcription yet, keep waiting
            if callStatus.lowercased().contains("ended") ||
               callStatus.lowercased().contains("finished") ||
               callStatus.lowercased().contains("completed") {
                NSLog("🔴 PHISHING SIMULATION: Call completed, but transcription not ready yet. Continuing to poll...")
            }
        }
        
        // Check if call has ended but no transcript was found
        let finalStatusCheck = await getCallTranscription(callId: callId)
        if finalStatusCheck && (lastTranscription?.isEmpty ?? true) {
            let isCallEnded = callStatus.lowercased().contains("ended") ||
                             callStatus.lowercased().contains("finished") ||
                             callStatus.lowercased().contains("completed")
            
            if isCallEnded {
                NSLog("🔴 PHISHING SIMULATION: Call has ended but no transcript found. Providing fake feedback...")
                await provideFakePhishingFeedback()
                return
            }
        }
        
        NSLog("⚠️ PHISHING SIMULATION: Timeout reached. Transcription may not be ready yet.")
    }
    
    // MARK: - Gemini Analysis
    
    /// Analyze phishing transcript using Gemini AI
    private func analyzePhishingTranscript(transcript: String) async {
        NSLog("🔴 GEMINI ANALYSIS: Starting phishing transcript analysis...")
        
        await MainActor.run {
            isAnalyzingTranscript = true
            phishingAnalysis = ""
        }
        
        let prompt = """
        Analyze this phishing call transcript and provide concise feedback on the effectiveness of the phishing attempt. Focus on:

        1. **Phishing Techniques Used**: What social engineering tactics were employed?
        2. **Effectiveness Assessment**: How successful was the phishing attempt?
        3. **Victim Response**: How did the victim react? Were they suspicious or compliant?
        4. **Key Vulnerabilities**: What made the victim susceptible or resistant?
        5. **Recommendations**: Brief suggestions for improving security awareness

        Keep the analysis concise (2-3 paragraphs max) and focus on actionable insights.

        TRANSCRIPT:
        \(transcript)
        """
        
        await geminiService.generateText(prompt: prompt, temperature: 0.7, maxTokens: 800)
        
        await MainActor.run {
            isAnalyzingTranscript = false
            phishingAnalysis = geminiService.lastResponse
            
            if !geminiService.errorMessage.isEmpty {
                phishingAnalysis = "Analysis Error: \(geminiService.errorMessage)"
                NSLog("❌ GEMINI ANALYSIS: Error - \(geminiService.errorMessage)")
            } else {
                NSLog("✅ GEMINI ANALYSIS: Analysis completed successfully")
                NSLog("🔴 GEMINI ANALYSIS: \(phishingAnalysis)")
            }
        }
    }
    
    /// Provide fake phishing feedback when no transcript is available after call completion
    private func provideFakePhishingFeedback() async {
        NSLog("🔴 FAKE FEEDBACK: Generating fake phishing analysis...")
        
        await MainActor.run {
            isAnalyzingTranscript = true
            phishingAnalysis = ""
        }
        
        // Generate realistic fake feedback based on common phishing scenarios
        let fakeFeedback = """
        **Phishing Analysis - No Transcript Available**
        
        **Phishing Techniques Used**: 
        The simulated phishing call likely employed common social engineering tactics such as urgency creation, authority impersonation, and fear-based manipulation. Without transcript access, we cannot determine the specific techniques used, but typical approaches include impersonating legitimate organizations, creating false urgency, and requesting sensitive information.
        
        **Effectiveness Assessment**: 
        The call appears to have completed, suggesting some level of engagement occurred. However, the lack of transcript data prevents detailed analysis of the interaction's success rate or victim response patterns.
        
        **Key Vulnerabilities**: 
        Common vulnerabilities in phishing scenarios include lack of awareness about social engineering tactics, insufficient verification procedures, and emotional decision-making under pressure. Users should be trained to verify caller identity through independent channels and never provide sensitive information over unsolicited calls.
        
        **Recommendations**: 
        Implement comprehensive security awareness training focusing on phone-based social engineering. Establish clear protocols for handling suspicious calls, including verification procedures and escalation processes. Consider implementing caller ID verification and recording capabilities for security analysis.
        
        *Note: This analysis is based on simulated data as no transcript was available for the completed call.*
        """
        
        await MainActor.run {
            isAnalyzingTranscript = false
            phishingAnalysis = fakeFeedback
            NSLog("✅ FAKE FEEDBACK: Fake analysis generated successfully")
            NSLog("🔴 FAKE FEEDBACK: \(fakeFeedback)")
        }
    }
    
    // MARK: - Private Methods
    
    private func makeCreateCallRequest(fromNumber: String, toNumber: String) async throws -> RetellCallResponse {
        // Use the correct v2 API endpoint for creating phone calls
        let endpoint = "\(baseURL)/v2/create-phone-call"
        
        guard let url = URL(string: endpoint) else {
            NSLog("❌ RetellAI: Invalid URL for endpoint: \(endpoint)")
            throw RetellAIError.invalidURL
        }
        
        NSLog("🔴 RetellAI: Creating call using endpoint: \(endpoint)")
        
        return try await makeRequestToURL(url, fromNumber: fromNumber, toNumber: toNumber)
    }
    
    private func makeRequestToURL(_ url: URL, fromNumber: String, toNumber: String) async throws -> RetellCallResponse {
        NSLog("🔴 RetellAI: Creating call request to URL: \(url.absoluteString)")
        NSLog("🔴 RetellAI: From: \(fromNumber), To: \(toNumber)")
        NSLog("🔴 RetellAI: API Key: \(apiKey.prefix(10))...")
        
        let request = RetellCallRequest(fromNumber: fromNumber, toNumber: toNumber)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
            NSLog("🔴 RetellAI: Request body encoded successfully")
        } catch {
            NSLog("❌ RetellAI: Failed to encode request body: \(error)")
            throw RetellAIError.encodingError(error)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                NSLog("❌ RetellAI: Invalid response type")
                throw RetellAIError.invalidResponse
            }
            
            NSLog("🔴 RetellAI: HTTP Response Status: \(httpResponse.statusCode)")
            NSLog("🔴 RetellAI: Response Headers: \(httpResponse.allHeaderFields)")
            
            // v2 API returns 201 for successful call creation, but we'll accept both 200 and 201
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                NSLog("❌ RetellAI: Error response body: \(responseString)")
                let errorMessage = "HTTP \(httpResponse.statusCode): \(responseString)"
                throw RetellAIError.apiError(httpResponse.statusCode, errorMessage)
            }
            
            let callResponse = try JSONDecoder().decode(RetellCallResponse.self, from: data)
            NSLog("✅ RetellAI: Call response decoded successfully")
            return callResponse
        } catch {
            NSLog("❌ RetellAI: Network request failed: \(error)")
            throw error
        }
    }
    
    private func makeGetCallRequest(callId: String) async throws -> RetellCallResponse {
        // Use the correct v2 API endpoint as per documentation
        let endpoint = "\(baseURL)/v2/get-call/\(callId)"
        
        guard let url = URL(string: endpoint) else {
            NSLog("❌ RetellAI: Invalid URL for endpoint: \(endpoint)")
            throw RetellAIError.invalidURL
        }
        
        NSLog("🔴 RetellAI: Getting call details from endpoint: \(endpoint)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                NSLog("❌ RetellAI: Invalid response type")
                throw RetellAIError.invalidResponse
            }
            
            NSLog("🔴 RetellAI: GET response status: \(httpResponse.statusCode) for endpoint: \(endpoint)")
            
            guard httpResponse.statusCode == 200 else {
                let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                NSLog("❌ RetellAI: GET error response body: \(responseString)")
                let errorMessage = "HTTP \(httpResponse.statusCode): \(responseString)"
                throw RetellAIError.apiError(httpResponse.statusCode, errorMessage)
            }
            
            let callDetails = try JSONDecoder().decode(RetellCallResponse.self, from: data)
            NSLog("✅ RetellAI: Successfully retrieved call details")
            return callDetails
        } catch {
            NSLog("❌ RetellAI: Failed to get call details: \(error)")
            throw error
        }
    }
}

// MARK: - Error Handling
enum RetellAIError: LocalizedError {
    case invalidURL
    case encodingError(Error)
    case invalidResponse
    case apiError(Int, String)
    case noCallId
    case noTranscription
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code, let message):
            return "API Error \(code): \(message)"
        case .noCallId:
            return "No call ID received"
        case .noTranscription:
            return "No transcription available"
        }
    }
}

// MARK: - Configuration Manager
class RetellConfig {
    static let shared = RetellConfig()
    
    private init() {}
    
    var apiKey: String {
        // Simple approach: try to read from .env file first
        if let envKey = readFromEnvFile() {
            return envKey
        }
        
        // Fallback to environment variable
        if let envVar = ProcessInfo.processInfo.environment["RETELL_API_KEY"], !envVar.isEmpty {
            return envVar
        }
        
        // Fallback to placeholder
        return "xxxxx"
    }
    
    var isConfigured: Bool {
        let key = apiKey
        return key != "xxxxx" && !key.isEmpty
    }
    
    private func readFromEnvFile() -> String? {
        // Look for .env file in current directory
        let currentDir = FileManager.default.currentDirectoryPath
        let envPath = "\(currentDir)/.env"
        
        guard FileManager.default.fileExists(atPath: envPath) else {
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: envPath, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip empty lines and comments
                if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                    continue
                }
                
                // Look for RETELL_API_KEY=
                if trimmedLine.hasPrefix("RETELL_API_KEY=") {
                    let key = String(trimmedLine.dropFirst(15)) // Remove "RETELL_API_KEY="
                    let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Return the key if it's not empty and not a placeholder
                    if !cleanKey.isEmpty && !cleanKey.contains("your_") {
                        return cleanKey
                    }
                }
            }
        } catch {
            print("Error reading .env file: \(error)")
        }
        
        return nil
    }
}
