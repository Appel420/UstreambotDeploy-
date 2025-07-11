import { type NextRequest, NextResponse } from "next/server"

// Guard against build-time crashes
if (!process.env.OPENAI_API_KEY && !process.env.GEMINI_API_KEY) {
  process.env.OPENAI_API_KEY = "DUMMY_KEY_FOR_BUILD_ONLY"
}

// Rate limiting store
const rateLimitStore = new Map<string, { count: number; resetTime: number }>()

function getRateLimitKey(request: NextRequest): string {
  const forwarded = request.headers.get("x-forwarded-for")
  const ip = forwarded ? forwarded.split(",")[0] : "127.0.0.1"
  return ip
}

function checkRateLimit(key: string): boolean {
  const now = Date.now()
  const windowMs = 15 * 60 * 1000 // 15 minutes
  const maxRequests = 50 // 50 requests per window

  const current = rateLimitStore.get(key)

  if (!current || now > current.resetTime) {
    rateLimitStore.set(key, { count: 1, resetTime: now + windowMs })
    return true
  }

  if (current.count >= maxRequests) {
    return false
  }

  current.count++
  return true
}

export async function POST(request: NextRequest) {
  try {
    // Rate limiting
    const rateLimitKey = getRateLimitKey(request)
    if (!checkRateLimit(rateLimitKey)) {
      return NextResponse.json({ error: "Rate limit exceeded. Please try again later." }, { status: 429 })
    }

    const body = await request.json()
    const { message, context = [] } = body

    // Input validation
    if (!message || typeof message !== "string") {
      return NextResponse.json({ error: "Message is required and must be a string" }, { status: 400 })
    }

    if (message.length > 1000) {
      return NextResponse.json({ error: "Message too long. Maximum 1000 characters." }, { status: 400 })
    }

    // Sanitize input
    const sanitizedMessage = message.trim().replace(/[<>]/g, "")

    // Build conversation context
    const systemPrompt = `You are DevAssist 4.2.0, an expert iOS development assistant. You specialize in:

- Swift programming language and best practices
- SwiftUI and UIKit development
- iOS app architecture (MVVM, MVC, Clean Architecture)
- Xcode debugging and optimization
- App Store guidelines and submission process
- Security best practices for iOS apps
- Performance optimization
- Core Data, CloudKit, and data persistence
- Networking and API integration
- Testing (Unit tests, UI tests)

Always provide:
- Accurate, up-to-date information
- Code examples when helpful
- Security considerations
- Best practices and Apple guidelines
- Clear, actionable advice

Format code blocks with proper syntax highlighting using triple backticks and language specification.`

    const messages = [
      { role: "system" as const, content: systemPrompt },
      ...context.slice(-10), // Last 10 messages for context
      { role: "user" as const, content: sanitizedMessage },
    ]

    let response: string

    // Try Gemini FIRST - this is the primary AI service
    if (process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY !== "DUMMY_KEY_FOR_BUILD_ONLY") {
      try {
        const { GoogleGenerativeAI } = await import("@google/generative-ai")
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY)
        const model = genAI.getGenerativeModel({ model: "gemini-pro" })

        // Convert messages to Gemini format
        const conversationHistory = messages
          .slice(1)
          .map((m) => `${m.role === "user" ? "Human" : "Assistant"}: ${m.content}`)
          .join("\n\n")

        const prompt = `${systemPrompt}\n\nConversation History:\n${conversationHistory}\n\nHuman: ${sanitizedMessage}\n\nAssistant:`

        const result = await model.generateContent(prompt)
        response = result.response.text()

        console.log("✅ Gemini API successful")
      } catch (geminiError) {
        console.error("❌ Gemini API failed:", geminiError)

        // Only fallback to OpenAI if Gemini fails
        if (process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== "DUMMY_KEY_FOR_BUILD_ONLY") {
          console.log("🔄 Falling back to OpenAI...")
          response = await callOpenAI(messages)
        } else {
          throw new Error("Both Gemini and OpenAI are unavailable")
        }
      }
    } else if (process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== "DUMMY_KEY_FOR_BUILD_ONLY") {
      // Use OpenAI only if Gemini is not available
      console.log("🔄 Using OpenAI (Gemini not configured)")
      response = await callOpenAI(messages)
    } else {
      throw new Error("No AI service configured - please set GEMINI_API_KEY or OPENAI_API_KEY")
    }

    return NextResponse.json({
      response,
      timestamp: new Date().toISOString(),
      provider: process.env.GEMINI_API_KEY ? "gemini-primary" : "openai-fallback",
      authenticated: true,
      developerMode: true,
    })
  } catch (error: any) {
    console.error("Chat API Error:", error)

    return NextResponse.json(
      {
        error: "I apologize, but I'm experiencing technical difficulties. Please try again in a moment.",
        details: process.env.NODE_ENV === "development" ? error.message : undefined,
      },
      { status: 500 },
    )
  }
}

async function callOpenAI(messages: any[]): Promise<string> {
  if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY === "DUMMY_KEY_FOR_BUILD_ONLY") {
    return "🛠 Build-time stub response - please configure OPENAI_API_KEY or GEMINI_API_KEY"
  }

  const { default: OpenAI } = await import("openai")
  const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
  })

  const completion = await openai.chat.completions.create({
    model: process.env.OPENAI_MODEL || "gpt-4o",
    messages,
    max_tokens: 1500,
    temperature: 0.7,
    presence_penalty: 0.1,
    frequency_penalty: 0.1,
  })

  return completion.choices[0]?.message?.content || "No response generated"
}
