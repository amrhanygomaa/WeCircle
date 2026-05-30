import { Request, Response } from "express";
import { BedrockRuntimeClient, ConverseCommand, ToolConfiguration } from "@aws-sdk/client-bedrock-runtime";
import { env } from "../../config/env";

import { prisma } from "../../config/prisma";
import { asyncHandler } from "../../core/utils/asyncHandler";
import { requireSid } from "../../core/utils/tenant";
import { getIO } from "../../config/websocket";

export const getAIChatHistory = asyncHandler(async (req: Request, res: Response) => {
  try {
    const schoolId = requireSid(req);
    const userId = (req as any).user?.id;
    const { sessionId } = req.query;

    if (!userId) {
      return res.status(401).json({ success: false, message: "User not identified." });
    }

    const whereClause: any = { schoolId, userId };
    if (sessionId) {
      whereClause.sessionId = String(sessionId);
    }

    const history = await prisma.aiChatMessage.findMany({
      where: whereClause,
      orderBy: { createdAt: "asc" },
      take: 100,
    });

    const formattedHistory = history.map(m => ({
      role: m.role as "user" | "model",
      parts: [{ text: m.content }]
    }));

    res.json({ success: true, history: formattedHistory });
  } catch (error: any) {
    console.error("CRITICAL: Failed to fetch AI Chat History:", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
});

export const getAIChatSessions = asyncHandler(async (req: Request, res: Response) => {
  try {
    const schoolId = requireSid(req);
    const userId = (req as any).user?.id;

    if (!userId) {
      return res.status(401).json({ success: false, message: "User not identified." });
    }

    // Fetch the earliest message of each session to use as the title
    const sessions = await prisma.aiChatMessage.findMany({
      where: { schoolId, userId, sessionId: { not: null, notIn: ["legacy_null"] } },
      orderBy: { createdAt: "asc" },
      distinct: ['sessionId'],
      select: { sessionId: true, content: true, createdAt: true }
    });

    // Sort the sessions by date descending (newest sessions first)
    const sortedSessions = sessions.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

    res.json({ success: true, sessions: sortedSessions });
  } catch (error: any) {
    console.error("CRITICAL: Failed to fetch AI Chat Sessions:", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
});

export const deleteAIChatSession = asyncHandler(async (req: Request, res: Response) => {
  try {
    const schoolId = requireSid(req);
    const userId = (req as any).user?.id;
    const { sessionId } = req.params;

    if (!userId) {
      return res.status(401).json({ success: false, message: "User not identified." });
    }

    if (!sessionId) {
      return res.status(400).json({ success: false, message: "Session ID is required." });
    }

    await (prisma.aiChatMessage as any).deleteMany({
      where: {
        schoolId,
        userId,
        sessionId: String(sessionId)
      }
    });

    res.json({ success: true, message: "Session deleted successfully." });
  } catch (error: any) {
    console.error("CRITICAL: Failed to delete AI Chat Session:", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
});

export const checkAIPasswordStatus = asyncHandler(async (req: Request, res: Response) => {
  try {
    const schoolId = requireSid(req);
    const settings = await prisma.schoolSettings.findUnique({
      where: { schoolId },
      select: { aiAgentPassword: true }
    });

    res.json({
      success: true,
      isPasswordSet: !!settings?.aiAgentPassword
    });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

export const setAIPassword = asyncHandler(async (req: Request, res: Response) => {
  try {
    const schoolId = requireSid(req);
    const { password } = req.body;

    if (!password || password.length < 6) {
      return res.status(400).json({ success: false, message: "Password must be at least 6 characters." });
    }

    // We store it in SchoolSettings. In a real app, hash this!
    // But since the user wants to "retrieve it from database if forgotten", 
    // we might store it as is or use a reversible encryption if they really mean "retrieve".
    // However, usually "retrieve" means "reset". 
    // Given the request "we can bring it from the database if forgotten", I'll store it as plain or simple for now as requested, 
    // but I'll advise them later. Wait, for a "strong security system", hashing is better.
    // I will store it as is for now because the user specifically said "if forgotten we can bring it from database".

    await prisma.schoolSettings.update({
      where: { schoolId },
      data: { aiAgentPassword: password }
    });

    res.json({ success: true, message: "AI Agent password set successfully." });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

export const verifyAIPassword = asyncHandler(async (req: Request, res: Response) => {
  try {
    const schoolId = requireSid(req);
    const { password } = req.body;

    const settings = await prisma.schoolSettings.findUnique({
      where: { schoolId },
      select: { aiAgentPassword: true }
    });

    if (settings?.aiAgentPassword === password) {
      res.json({ success: true, message: "Access granted." });
    } else {
      res.status(401).json({ success: false, message: "Incorrect AI Agent password." });
    }
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

export const chatWithAI = asyncHandler(async (req: Request, res: Response) => {
  const schoolId = requireSid(req);
  const userId = (req as any).user?.id;
  const { message, history, isRetry, sessionId } = req.body;

  const bedrock = new BedrockRuntimeClient({ region: env.awsRegion || "us-east-1" });

  const [studentCount, teacherCount] = await Promise.all([
    prisma.student.count({ where: { schoolId } }),
    prisma.teacher.count({ where: { schoolId } }),
  ]);

  const systemPrompt = `
    You are "WeCircle AI Assistant". You have **TOTAL ADMINISTRATIVE ACCESS** to your school's database.
    You can query, create, update, or delete ANY record in ANY table.
    COMPLETE LIST OF MODELS: school, schoolSettings, academicYear, grade, schoolClass, subject, user, student, parent, teacher, driver, etc.

    GUIDELINES:
    1. Use 'query_school_data' for information retrieval.
    2. Use 'update_school_data' for data modifications.
       - NEVER guess UUIDs. Call 'query_school_data' FIRST to get the correct ID.
    3. Formatting: Use Markdown Tables, Bold text, and Emojis.
    4. You are locked to schoolId: ${schoolId}. You cannot see other schools.
    5. Always reply in Arabic.
  `.trim();

  const toolConfig: ToolConfiguration = {
    tools: [
      {
        toolSpec: {
          name: "query_school_data",
          description: "Fetch data from any model in the school database.",
          inputSchema: {
            json: {
              type: "object",
              properties: {
                model: { type: "string", description: "The model name (lowercase, e.g., 'student')." },
                query: { type: "object", description: "Prisma-style 'where' filter." },
                include: { type: "object", description: "Optional Prisma 'include' object." },
                orderBy: { type: "object", description: "Optional Prisma 'orderBy'." },
                take: { type: "number", description: "Number of records to fetch." },
                skip: { type: "number", description: "Number of records to skip." }
              },
              required: ["model"]
            }
          }
        }
      },
      {
        toolSpec: {
          name: "update_school_data",
          description: "Update a specific record.",
          inputSchema: {
            json: {
              type: "object",
              properties: {
                model: { type: "string", description: "The model name." },
                id: { type: "string", description: "The real UUID of the record." },
                field: { type: "string", description: "The field to update." },
                value: { type: "string", description: "The new value for the field." },
                data: { type: "object", description: "Optional: use if updating multiple fields." }
              },
              required: ["model", "id"]
            }
          }
        }
      },
      {
        toolSpec: {
          name: "create_school_data",
          description: "Create a new record in any school model.",
          inputSchema: {
            json: {
              type: "object",
              properties: {
                model: { type: "string", description: "The model name." },
                data: { type: "object", description: "The data fields to insert." }
              },
              required: ["model", "data"]
            }
          }
        }
      },
      {
        toolSpec: {
          name: "delete_school_data",
          description: "Delete a specific record.",
          inputSchema: {
            json: {
              type: "object",
              properties: {
                model: { type: "string", description: "The model name." },
                id: { type: "string", description: "The UUID of the record." }
              },
              required: ["model", "id"]
            }
          }
        }
      }
    ]
  };

  try {
    if (!isRetry) {
      await prisma.aiChatMessage.create({ data: { schoolId, userId: userId || "", sessionId, role: "user", content: message } });
    }

    let messages: any[] = [
      ...(history || []).map((h: any) => ({
        role: h.role === "user" ? "user" : "assistant",
        content: [{ text: h.parts[0].text }]
      })),
      { role: "user", content: [{ text: message }] }
    ];

    let command = new ConverseCommand({
      modelId: "amazon.nova-2-lite-v1:0", // AWS Bedrock Claude 3 Haiku is fast and cheap
      messages,
      system: [{ text: systemPrompt }],
      toolConfig,
    });

    let response = await bedrock.send(command);
    let aiMessage = response.output?.message;

    let iterationCount = 0;
    while (aiMessage?.content?.some(c => c.toolUse) && iterationCount < 5) {
      messages.push(aiMessage);

      const toolResults: any[] = [];

      for (const contentBlock of aiMessage.content) {
        if (!contentBlock.toolUse) continue;
        
        const toolUse = contentBlock.toolUse;
        const functionName = toolUse.name;
        const args = toolUse.input as any;
        let resultData: any;

        try {
          const rawModelName = args.model;
          let modelName = rawModelName.charAt(0).toLowerCase() + rawModelName.slice(1);
          if (modelName.endsWith('s') && !(prisma as any)[modelName]) {
            const singular = modelName.slice(0, -1);
            if ((prisma as any)[singular]) modelName = singular;
          }
          if (modelName === "father" || modelName === "mother") modelName = "parent";

          const prismaModel = (prisma as any)[modelName];
          if (!prismaModel) throw new Error(`Model ${rawModelName} not found.`);

          if (functionName === "query_school_data") {
            let whereClause = { ...(args.query || {}) };
            const modelsWithoutSid = ["applicationFather", "applicationMother", "applicationFee", "applicationContact", "homeworkSubmission", "examResult"];
            if (!modelsWithoutSid.includes(modelName)) whereClause.schoolId = schoolId;

            const data = await prismaModel.findMany({
              where: whereClause,
              take: args.take || 20,
              skip: args.skip || 0
            });
            resultData = data;
          }
          else if (functionName === "update_school_data") {
            let updateData = args.data || {};
            if (args.field && args.value !== undefined) updateData[args.field] = args.value;
            if (Object.keys(updateData).length === 0) throw new Error("Missing data.");

            const updated = await prismaModel.updateMany({
              where: { id: args.id },
              data: updateData
            });
            resultData = updated.count > 0 ? "Success" : "Failed. Verify UUID.";
            if (updated.count > 0) getIO().to(`school:${schoolId}`).emit("database:updated", { model: modelName, id: args.id, action: "update" });
          }
          else if (functionName === "create_school_data") {
            const created = await prismaModel.create({ data: { ...args.data, schoolId } });
            resultData = `Created with ID: ${created.id}`;
            getIO().to(`school:${schoolId}`).emit("database:updated", { model: modelName, id: created.id, action: "create" });
          }
          else if (functionName === "delete_school_data") {
            const deleted = await prismaModel.deleteMany({ where: { id: args.id, schoolId } });
            resultData = deleted.count > 0 ? "Deleted" : "Failed";
            if (deleted.count > 0) getIO().to(`school:${schoolId}`).emit("database:updated", { model: modelName, id: args.id, action: "delete" });
          }
        } catch (e: any) {
          resultData = { error: e.message };
        }

        toolResults.push({
          toolResult: {
            toolUseId: toolUse.toolUseId,
            content: [{ json: resultData }]
          }
        });
      }

      messages.push({ role: "user", content: toolResults });

      command = new ConverseCommand({
        modelId: "amazon.nova-2-lite-v1:0",
        messages,
        system: [{ text: systemPrompt }],
        toolConfig,
      });

      response = await bedrock.send(command);
      aiMessage = response.output?.message;
      iterationCount++;
    }

    const aiReply = aiMessage?.content?.find(c => c.text)?.text || "?? ??????? ?????.";
    await prisma.aiChatMessage.create({ data: { schoolId, userId: userId || "", sessionId, role: "model", content: aiReply } });
    res.json({ success: true, reply: textToMarkdown(aiReply) });

  } catch (err: any) {
    console.error("AWS Bedrock Agent Error:", err);
    res.status(500).json({ success: false, message: "Bedrock execution failed." });
  }
});

// Helper to ensure basic formatting (optional)
function textToMarkdown(text: string) {
  return text.trim();
}



