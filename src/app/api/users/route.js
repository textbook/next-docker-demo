import { PrismaClient } from "@prisma/client";

export async function GET() {
  const users = await new PrismaClient().user.findMany();
  return Response.json({ users });
}
