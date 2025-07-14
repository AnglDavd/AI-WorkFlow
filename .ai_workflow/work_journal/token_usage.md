# Token Usage Tracking

## Overview
This document tracks token usage across different AI model providers to support the framework's token economy optimization goals.

## Token Usage Records

### Usage Summary
| Provider | Model | Total Sessions | Total Tokens Used | Average per Session |
|----------|-------|----------------|------------------|-------------------|
| OpenAI | GPT-4 | 1 | 2,300 | 2,300 |
| Anthropic | Claude-3-Opus | 1 | 3,700 | 3,700 |
| Google | Gemini-1.5-Pro | 1 | 2,750 | 2,750 |
| **TOTAL** | **All Models** | **3** | **8,750** | **2,917** |

### Detailed Usage Log

#### Session 1 - OpenAI GPT-4
- **Timestamp**: 2025-07-09T10:15:00Z
- **Model Provider**: OpenAI
- **Model Name**: GPT-4
- **Input Tokens**: 1,500
- **Output Tokens**: 800
- **Total Tokens**: 2,300
- **Cost Estimate**: $0.069 (approx.)

#### Session 2 - Anthropic Claude-3-Opus
- **Timestamp**: 2025-07-09T10:16:00Z
- **Model Provider**: Anthropic
- **Model Name**: Claude-3-Opus
- **Input Tokens**: 2,200
- **Output Tokens**: 1,500
- **Total Tokens**: 3,700
- **Cost Estimate**: $0.185 (approx.)

#### Session 3 - Google Gemini-1.5-Pro
- **Timestamp**: 2025-07-09T10:17:00Z
- **Model Provider**: Google
- **Model Name**: Gemini-1.5-Pro
- **Input Tokens**: 1,800
- **Output Tokens**: 950
- **Total Tokens**: 2,750
- **Cost Estimate**: $0.055 (approx.)

## Usage Analysis

### Token Efficiency Metrics
- **Most Efficient Model**: Gemini-1.5-Pro (lowest cost per token)
- **Highest Token Usage**: Claude-3-Opus (3,700 tokens)
- **Average Session Length**: 2,917 tokens
- **Total Estimated Cost**: $0.309

### Optimization Recommendations
1. **Cost Optimization**: Consider using Gemini-1.5-Pro for routine tasks
2. **Token Reduction**: Claude-3-Opus sessions are consuming high tokens
3. **Model Selection**: GPT-4 shows balanced input/output ratio

## Workflow Integration

### Adding New Usage Records
To add a new token usage record, append to the "Detailed Usage Log" section:

```markdown
#### Session N - [Provider Model]
- **Timestamp**: YYYY-MM-DDTHH:MM:SSZ
- **Model Provider**: [Provider]
- **Model Name**: [Model]
- **Input Tokens**: [Number]
- **Output Tokens**: [Number]
- **Total Tokens**: [Number]
- **Cost Estimate**: $[Amount] (approx.)
```

### Automated Tracking
This file integrates with the following workflows:
- `collect_token_usage.md` - Automated collection during execution
- `analyze_token_costs.md` - Cost analysis and optimization
- `review-token-economy.md` - Periodic review and recommendations

## Data Format Migration

### From JSON to Markdown
Original JSON format:
```json
{"timestamp": "2025-07-09T10:15:00Z", "model_provider": "openai", "model_name": "gpt-4", "input_tokens": 1500, "output_tokens": 800, "total_tokens": 2300}
```

Converted to structured markdown format above for better readability and integration with the framework's documentation approach.

## Historical Data

### Monthly Summary (July 2025)
- **Total Sessions**: 3
- **Total Tokens**: 8,750
- **Total Estimated Cost**: $0.309
- **Average Cost per Session**: $0.103

### Trends
- Initial framework usage shows balanced distribution across providers
- Need more data to establish meaningful trends
- Cost tracking is essential for budget planning

## Notes
- This file replaces the previous `token_usage.log` JSON file
- All token usage is now tracked in markdown format
- Cost estimates are based on current provider pricing
- Integration with automated workflows enables real-time tracking