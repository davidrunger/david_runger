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
        "current_user": {
          "$ref": "#/definitions/CurrentUser"
        },
        "nonce": {
          "type": "string",
          "format": "uuid"
        },
        "recent_gantt_chart_metadatas": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RecentGanttChartMetadata"
          }
        }
      },
      "required": ["current_user", "nonce", "recent_gantt_chart_metadatas"],
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
        }
      },
      "required": ["email", "id"],
      "title": "CurrentUser"
    },
    "RecentGanttChartMetadata": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "pretty_start_time": {
          "type": "string"
        },
        "branch": {
          "type": "string"
        },
        "pretty_github_run_info": {
          "type": "string"
        },
        "github_run_id": {
          "type": "integer"
        },
        "github_run_attempt": {
          "type": "integer"
        },
        "dom_id": {
          "type": "string"
        },
        "run_times": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RunTime"
          }
        }
      },
      "required": [
        "branch",
        "dom_id",
        "github_run_attempt",
        "github_run_id",
        "pretty_github_run_info",
        "pretty_start_time",
        "run_times"
      ],
      "title": "RecentGanttChartMetadata"
    },
    "RunTime": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "name": {
          "type": "string"
        },
        "started_at": {
          "type": "string",
          "format": "date-time"
        },
        "stopped_at": {
          "type": "string",
          "format": "date-time"
        },
        "seconds": {
          "type": "number"
        }
      },
      "required": ["name", "seconds", "started_at", "stopped_at"],
      "title": "RunTime"
    }
  }
} as const;

export type CiStepResultsIndexBootstrap = FromSchema<typeof schema>;
