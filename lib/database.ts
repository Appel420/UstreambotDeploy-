import { createClient } from "@supabase/supabase-js"
import { config } from "./config"

export const supabase = createClient(config.supabase.url, config.supabase.anonKey)

export interface ChatSession {
  id: string
  user_id: string
  title: string
  created_at: string
  updated_at: string
}

export interface ChatMessage {
  id: string
  session_id: string
  content: string
  is_user: boolean
  created_at: string
}

export class DatabaseService {
  async createChatSession(userId: string, title: string): Promise<ChatSession> {
    const { data, error } = await supabase.from("chat_sessions").insert({ user_id: userId, title }).select().single()

    if (error) throw error
    return data
  }

  async saveChatMessage(sessionId: string, content: string, isUser: boolean): Promise<ChatMessage> {
    const { data, error } = await supabase
      .from("chat_messages")
      .insert({
        session_id: sessionId,
        content,
        is_user: isUser,
      })
      .select()
      .single()

    if (error) throw error
    return data
  }

  async getChatHistory(sessionId: string): Promise<ChatMessage[]> {
    const { data, error } = await supabase
      .from("chat_messages")
      .select("*")
      .eq("session_id", sessionId)
      .order("created_at", { ascending: true })

    if (error) throw error
    return data || []
  }
}

export const dbService = new DatabaseService()
