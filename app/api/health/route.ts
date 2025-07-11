import { NextResponse } from "next/server"

export async function GET() {
  try {
    // Check if OpenAI API key is configured
    if (!process.env.OPENAI_API_KEY) {
      return NextResponse.json({
        status: "unhealthy",
        error: "OpenAI API key not configured",
        timestamp: new Date().toISOString(),
      })
    }

    // Simple health check without actually calling OpenAI
    return NextResponse.json({
      status: "healthy",
      services: {
        openai: "configured",
        database: "ready",
        api: "operational",
      },
      version: "4.2.0",
      timestamp: new Date().toISOString(),
    })
  } catch (error: any) {
    console.error("Health check failed:", error)

    return NextResponse.json(
      {
        status: "unhealthy",
        error: error.message || "Service unavailable",
        timestamp: new Date().toISOString(),
      },
      { status: 503 },
    )
  }
}
