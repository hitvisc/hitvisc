export function mapBooleanToFlag(value: boolean) {
  return {
    ['true']: 'Y',
    ['false']: 'N',
  }[value.toString()];
}
