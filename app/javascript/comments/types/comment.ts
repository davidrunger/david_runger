import type { UserSerializerPublic } from '@/types';

export interface Comment {
  content: string;
  created_at: string;
  id: number;
  parent_id: number | null;
  replies: Array<Comment>;
  user: UserSerializerPublic;
}
