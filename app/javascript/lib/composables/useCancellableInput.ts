import { nextTick, ref, Ref } from 'vue';

interface UseCancellableInputOptions {
  onUpdate: (newValue: string) => void;
}

interface UseCancellableInputReturn {
  editableRef: Ref<string>;
  isEditing: Ref<boolean>;
  startEditing: (initialValue: string) => void;
  inputRef: Ref<HTMLInputElement | null>;
  inputEventHandlers: {
    onBlur: () => void;
    onKeydown: (event: KeyboardEvent) => void;
  };
}

export function useCancellableInput(
  options: UseCancellableInputOptions,
): UseCancellableInputReturn {
  const { onUpdate } = options;

  const isEditing = ref<boolean>(false);
  const editableRef = ref<string>('');
  const inputRef = ref<HTMLInputElement | null>(null);

  function startEditing(initialValue: string): void {
    editableRef.value = initialValue;
    isEditing.value = true;

    nextTick(() => {
      if (inputRef.value) {
        inputRef.value.focus();
      }
    });
  }

  function saveChanges(): void {
    isEditing.value = false;
    onUpdate(editableRef.value);
  }

  function cancelEditing(): void {
    isEditing.value = false;
  }

  const inputEventHandlers = {
    onBlur: saveChanges,
    onKeydown: (event: KeyboardEvent) => {
      if (event.key === 'Enter') {
        saveChanges();
      } else if (event.key === 'Escape') {
        cancelEditing();
      }
    },
  };

  return {
    editableRef,
    isEditing,
    startEditing,
    inputRef,
    inputEventHandlers,
  };
}
