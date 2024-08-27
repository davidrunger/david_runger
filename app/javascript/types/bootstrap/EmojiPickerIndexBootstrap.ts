// This is a generated file. Do not edit this file directly.

import { FromSchema } from 'json-schema-to-ts';

const schema = {
  "$schema": "http://json-schema.org/draft-06/schema#",
  "$ref": "#/definitions/Root",
  "definitions": {
    "Root": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "nonce": {
          "type": "string",
          "format": "uuid"
        },
        "current_user": {
          "$ref": "#/definitions/CurrentUser"
        }
      },
      "required": ["current_user", "nonce"],
      "title": "Root"
    },
    "CurrentUser": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "email": {
          "type": "string"
        },
        "id": {
          "type": "integer"
        },
        "emoji_boosts": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/EmojiBoost"
          }
        }
      },
      "required": ["email", "emoji_boosts", "id"],
      "title": "CurrentUser"
    },
    "EmojiBoost": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "symbol": {
          "type": "string"
        },
        "boostedName": {
          "type": "string"
        }
      },
      "required": ["boostedName", "symbol"],
      "title": "EmojiBoost"
    }
  }
} as const;

export type EmojiPickerIndexBootstrap = FromSchema<typeof schema>;