import client from "../prisma";

export const dynamic = "force-dynamic";

export async function GET() {
  const users = await client.user.findMany();
  return Response.json(users);
}
