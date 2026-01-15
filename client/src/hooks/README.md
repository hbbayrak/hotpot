# Hooks

Custom React hooks for the CCD platform.

## useDebounce

Debounces a value, delaying updates until after a specified delay has passed since the last change.

### Signature

```typescript
function useDebounce<T>(value: T, delay?: number): T
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `T` | - | The value to debounce |
| `delay` | `number` | `500` | Delay in milliseconds |

### Returns

The debounced value of type `T`.

### Usage

```tsx
import { useState } from 'react';
import { useDebounce } from '@/hooks/useDebounce';

function SearchInput() {
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearch = useDebounce(searchTerm, 300);

  // API call only fires when user stops typing for 300ms
  useEffect(() => {
    if (debouncedSearch) {
      searchApi(debouncedSearch);
    }
  }, [debouncedSearch]);

  return (
    <input
      value={searchTerm}
      onChange={(e) => setSearchTerm(e.target.value)}
      placeholder="Search..."
    />
  );
}
```

### Common Use Cases

1. **Search inputs** - Prevent API calls on every keystroke
2. **Form validation** - Delay validation until user stops typing
3. **Resize handlers** - Throttle expensive calculations
4. **Auto-save** - Delay save operations while user is editing

### Implementation

```typescript
import { useEffect, useState } from 'react';

export const useDebounce = <T>(value: T, delay?: number): T => {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay || 500);

    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
};
```
