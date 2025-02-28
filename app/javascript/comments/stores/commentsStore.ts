import { defineStore } from 'pinia';

import type { Comment } from '@/comments/types/comment';
import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import { api_comment_path, api_comments_path } from '@/rails_assets/routes';
import { http } from '@/shared/http';
import type { UniversalBootstrapData } from '@/shared/types';
import type { Intersection } from '@/types';
import { CommentCreateResponse } from '@/types/responses/CommentCreateResponse';
import { CommentsIndexResponse } from '@/types/responses/CommentsIndexResponse';
import { CommentUpdateResponse } from '@/types/responses/CommentUpdateResponse';
import type { Comment as SerializedComment } from '@/types/serializers';

const bootstrap = untypedBootstrap as UniversalBootstrapData;

function findCommentRecursively(
  comments: Array<Comment>,
  id: number,
): Comment | undefined {
  for (const comment of comments) {
    if (comment.id === id) return comment;

    const found = findCommentRecursively(comment.replies, id);
    if (found) return found;
  }
}

function removeReplyRecursively(replies: Array<Comment>, id: number) {
  const index = replies.findIndex((r) => r.id === id);
  if (index !== -1) {
    replies.splice(index, 1);
    return;
  }

  for (const reply of replies) {
    removeReplyRecursively(reply.replies, id);
  }
}

function rootCommentsWithRepliesTree(
  flatComments: Array<Omit<Comment, 'replies'>>,
): Array<Comment> {
  // Create a map for quick lookup of comments by their ID.
  const commentMap: Record<number, Comment> = {};

  // Initialize empty 'replies' array for each comment.
  flatComments.forEach((comment) => {
    commentMap[comment.id] = {
      ...comment,
      replies: [],
    };
  });

  // Build the tree structure.
  const rootComments: Array<Comment> = [];

  flatComments.forEach((comment) => {
    const commentWithReplies = commentMap[comment.id];

    if (comment.parent_id === null) {
      // This is a root comment.
      rootComments.push(commentWithReplies);
    } else {
      // This is a reply, add it to its parent's replies.
      commentMap[comment.parent_id].replies.push(commentWithReplies);
    }
  });

  return rootComments;
}

export const useCommentsStore = defineStore('comments', {
  state: () => ({
    comments: [] as Array<Comment>,
    currentUser: bootstrap.current_user,
  }),

  actions: {
    async addComment(content: string, parentId: number | null = null) {
      const commentResponse = await http.post<
        Intersection<SerializedComment, CommentCreateResponse>
      >(api_comments_path(), {
        comment: {
          content,
          parent_id: parentId,
        },
      });

      const newComment: Comment = Object.assign(commentResponse, {
        replies: [],
      });

      if (parentId) {
        const parent = findCommentRecursively(this.comments, parentId);
        parent?.replies.push(newComment);
      } else {
        this.comments.push(newComment);
      }
    },

    async deleteComment(id: number) {
      const commentResponse = await http.delete<SerializedComment | null>(
        api_comment_path(id),
      );

      if (commentResponse) {
        const comment = findCommentRecursively(this.comments, id);

        if (comment) {
          Object.assign(comment, commentResponse);
        }
      } else {
        this.comments = this.comments.filter((c) => c.id !== id);

        for (const comment of this.comments) {
          removeReplyRecursively(comment.replies, id);
        }
      }
    },

    async fetchInitialData() {
      this.comments = rootCommentsWithRepliesTree(
        await http.get<
          Intersection<Array<SerializedComment>, CommentsIndexResponse>
        >(api_comments_path()),
      );
    },

    async updateComment(id: number, content: string) {
      const updatedCommentResponse = await http.patch<
        Intersection<SerializedComment, CommentUpdateResponse>
      >(api_comment_path(id), { comment: { content } });

      const comment = findCommentRecursively(this.comments, id);

      if (comment) {
        Object.assign(comment, updatedCommentResponse);
      }
    },
  },
});
