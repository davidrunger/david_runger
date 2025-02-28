import TypelizerComment from '@/types/serializers/Comment';

export interface Comment extends TypelizerComment {
  replies: Array<Comment>;
}
