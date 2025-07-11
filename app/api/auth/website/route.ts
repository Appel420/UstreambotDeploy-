import { type NextRequest, NextResponse } from "next/server"

// Website permission management
const authorizedWebsites = new Map<
  string,
  {
    permissions: string[]
    owner: string
    authenticated: boolean
  }
>()

export async function POST(request: NextRequest) {
  try {
    const { url } = await request.json()

    // Validate website URL
    if (!url || typeof url !== "string") {
      return NextResponse.json({ error: "Valid website URL required" }, { status: 400 })
    }

    // Check if website is pre-authorized
    const websiteData = authorizedWebsites.get(url) || {
      permissions: ["read", "write", "deploy"],
      owner: "authenticated_user",
      authenticated: true,
    }

    // Store authorization
    authorizedWebsites.set(url, websiteData)

    return NextResponse.json({
      success: true,
      permissions: websiteData.permissions,
      authenticated: websiteData.authenticated,
    })
  } catch (error) {
    console.error("Website authentication error:", error)
    return NextResponse.json({ error: "Authentication failed" }, { status: 500 })
  }
}

export async function GET(request: NextRequest) {
  const url = request.nextUrl.searchParams.get("url")

  if (!url) {
    return NextResponse.json({ error: "URL parameter required" }, { status: 400 })
  }

  const websiteData = authorizedWebsites.get(url)

  if (!websiteData) {
    return NextResponse.json({ error: "Website not authorized" }, { status: 403 })
  }

  return NextResponse.json({
    permissions: websiteData.permissions,
    authenticated: websiteData.authenticated,
    owner: websiteData.owner,
  })
}
