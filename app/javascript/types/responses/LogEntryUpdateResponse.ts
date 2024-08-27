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
        "data": {
          "type": ["number", "string"]
        },
        "log_id": {
          "type": "integer"
        },
        "note": {
          "type": ["null", "string"]
        },
        "created_at": {
          "type": "string",
          "format": "date-time"
        }
      },
      "required": ["created_at", "data", "id", "log_id", "note"],
      "title": "Root"
    }
  }
} as const;

export type LogEntryUpdateResponse = FromSchema<typeof schema>;