import type { AgentContext, ConvMessage, Conversation, ConvStatus } from "./shopTypes";

export const HANDOFF_QUEUE_KEY = "servicebot_local_handoff_queue_v1";

export interface LocalHandoff {
  conversation: Conversation;
  messages: ConvMessage[];
  saved_at: number;
}

function readRaw(): LocalHandoff[] {
  if (typeof window === "undefined") return [];
  const raw = window.localStorage.getItem(HANDOFF_QUEUE_KEY);
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw) as LocalHandoff[];
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    window.localStorage.removeItem(HANDOFF_QUEUE_KEY);
    return [];
  }
}

function writeRaw(items: LocalHandoff[]) {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(HANDOFF_QUEUE_KEY, JSON.stringify(items.slice(0, 50)));
  window.dispatchEvent(new Event("servicebot-local-handoffs"));
}

function shouldKeep(status: ConvStatus) {
  return status === "queued" || status === "human";
}

export function readLocalHandoffs(): LocalHandoff[] {
  return readRaw()
    .filter((item) => item.conversation?.conversation_id && shouldKeep(item.conversation.status))
    .sort((a, b) => (b.conversation.last_message_at || b.saved_at) - (a.conversation.last_message_at || a.saved_at));
}

export function findLocalHandoff(conversationId: string): LocalHandoff | null {
  return readLocalHandoffs().find((item) => item.conversation.conversation_id === conversationId) ?? null;
}

export function upsertLocalHandoff(conversation: Conversation, messages: ConvMessage[]) {
  if (!shouldKeep(conversation.status)) {
    removeLocalHandoff(conversation.conversation_id);
    return;
  }
  const saved: LocalHandoff = { conversation, messages, saved_at: Date.now() / 1000 };
  const existing = readRaw().filter((item) => item.conversation?.conversation_id !== conversation.conversation_id);
  writeRaw([saved, ...existing]);
}

export function removeLocalHandoff(conversationId: string) {
  writeRaw(readRaw().filter((item) => item.conversation?.conversation_id !== conversationId));
}

export function mergeHandoffConversations(remote: Conversation[], status: string): Conversation[] {
  const byId = new Map<string, Conversation>();
  remote.forEach((conversation) => byId.set(conversation.conversation_id, conversation));
  for (const item of readLocalHandoffs()) {
    const conversation = item.conversation;
    if (status !== "all" && conversation.status !== status) continue;
    if (!byId.has(conversation.conversation_id)) byId.set(conversation.conversation_id, conversation);
  }
  return Array.from(byId.values()).sort((a, b) => {
    if (b.priority !== a.priority) return b.priority - a.priority;
    return b.last_message_at - a.last_message_at;
  });
}

export function localHandoffCounts(): Record<string, number> {
  return readLocalHandoffs().reduce<Record<string, number>>((counts, item) => {
    counts[item.conversation.status] = (counts[item.conversation.status] ?? 0) + 1;
    return counts;
  }, {});
}

export function localHandoffContext(conversationId: string): AgentContext | null {
  const item = findLocalHandoff(conversationId);
  if (!item) return null;
  return {
    conversation: item.conversation,
    messages: item.messages,
    customer: {
      customer_id: item.conversation.customer_id,
      orders: [],
      memories: [],
    },
  };
}
