const httpUrlRegex =
  /(https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_+.~#?&/=]*[a-zA-Z0-9/])(?:#[-a-zA-Z0-9()@:%_+.~#?&/=]*)?)/gi;

export function linkify(text: string): string {
  return text.replace(httpUrlRegex, '<a href="$1">$1</a>');
}
