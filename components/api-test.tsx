"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { CheckCircle, XCircle, Loader2 } from "lucide-react"

interface TestResult {
  name: string
  status: "success" | "error" | "loading"
  message: string
}

export function ApiTest() {
  const [tests, setTests] = useState<TestResult[]>([])
  const [isRunning, setIsRunning] = useState(false)

  const runTests = async () => {
    setIsRunning(true)
    setTests([])

    const testCases = [
      {
        name: "Health Check",
        test: async () => {
          const response = await fetch("/api/health")
          const data = await response.json()
          return { success: response.ok, message: data.status || "Unknown" }
        },
      },
      {
        name: "Chat API Test",
        test: async () => {
          const response = await fetch("/api/chat", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ message: "Hello, can you respond with just 'API Working'?" }),
          })
          const data = await response.json()
          return {
            success: response.ok && !data.error,
            message: data.response || data.error || "No response",
          }
        },
      },
    ]

    for (const testCase of testCases) {
      setTests((prev) => [...prev, { name: testCase.name, status: "loading", message: "Running..." }])

      try {
        const result = await testCase.test()
        setTests((prev) =>
          prev.map((test) =>
            test.name === testCase.name
              ? {
                  name: testCase.name,
                  status: result.success ? "success" : "error",
                  message: result.message,
                }
              : test,
          ),
        )
      } catch (error) {
        setTests((prev) =>
          prev.map((test) =>
            test.name === testCase.name
              ? {
                  name: testCase.name,
                  status: "error",
                  message: error instanceof Error ? error.message : "Unknown error",
                }
              : test,
          ),
        )
      }

      // Small delay between tests
      await new Promise((resolve) => setTimeout(resolve, 500))
    }

    setIsRunning(false)
  }

  return (
    <Card className="w-full max-w-2xl mx-auto">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          DevAssist 4.2.0 API Tests
          <Button onClick={runTests} disabled={isRunning}>
            {isRunning ? <Loader2 className="w-4 h-4 animate-spin" /> : "Run Tests"}
          </Button>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {tests.length === 0 && !isRunning && (
          <p className="text-gray-500 text-center py-8">Click "Run Tests" to check API status</p>
        )}

        {tests.map((test, index) => (
          <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
            <div className="flex items-center space-x-3">
              {test.status === "loading" && <Loader2 className="w-5 h-5 animate-spin text-blue-500" />}
              {test.status === "success" && <CheckCircle className="w-5 h-5 text-green-500" />}
              {test.status === "error" && <XCircle className="w-5 h-5 text-red-500" />}
              <span className="font-medium">{test.name}</span>
            </div>
            <div className="flex items-center space-x-2">
              <Badge
                variant={test.status === "success" ? "default" : test.status === "error" ? "destructive" : "secondary"}
              >
                {test.status}
              </Badge>
              <span className="text-sm text-gray-600 max-w-xs truncate">{test.message}</span>
            </div>
          </div>
        ))}
      </CardContent>
    </Card>
  )
}
