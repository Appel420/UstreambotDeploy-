import { config } from "./config"

// Guard against build-time crashes
if (!process.env.OPENAI_API_KEY) {
  process.env.OPENAI_API_KEY = "DUMMY_KEY_FOR_BUILD_ONLY"
}

class AIService {
  private _openai: any

  private async getClient() {
    if (this._openai) return this._openai
    const { default: OpenAI } = await import("openai")
    this._openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY! })
    return this._openai
  }

  async generateResponse(message: string, context: string[] = []) {
    const client = await this.getClient()

    if (process.env.OPENAI_API_KEY === "DUMMY_KEY_FOR_BUILD_ONLY") {
      return "🛠 Build-time stub response"
    }

    const completion = await client.chat.completions.create({
      model: config.openai.model,
      messages: [
        { role: "system", content: "You are DevAssist 4.2.0 ..." },
        ...context.map((c) => ({ role: "assistant", content: c })),
        { role: "user", content: message },
      ],
      max_tokens: config.openai.maxTokens,
    })

    return completion.choices[0]?.message?.content ?? "No answer."
  }
}

export const aiService = new AIService()
