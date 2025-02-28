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
        "id": {
          "type": "integer"
        },
        "name": {
          "type": "string"
        },
        "notes": {
          "type": ["null", "string"]
        },
        "own_store": {
          "type": "boolean"
        },
        "private": {
          "type": "boolean"
        },
        "viewed_at": {
          "type": "string",
          "format": "date-time"
        },
        "items": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Item"
          }
        }
      },
      "required": [
        "id",
        "items",
        "name",
        "notes",
        "own_store",
        "private",
        "viewed_at"
      ],
      "title": "Root"
    },
    "Item": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "id": {
          "type": "integer"
        },
        "name": {
          "type": "string"
        },
        "needed": {
          "type": "integer"
        },
        "store_id": {
          "type": "integer"
        }
      },
      "required": ["id", "name", "needed", "store_id"],
      "title": "Item"
    }
  }
} as const;

export type StoreCreateResponse = FromSchema<typeof schema>;
