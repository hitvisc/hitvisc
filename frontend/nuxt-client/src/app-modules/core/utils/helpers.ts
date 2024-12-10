import { z, ZodSchema } from 'zod';

/**
 * nameof
 * Returns the passed property name but will generate a compile
 * time error when the property name does not exist on type T
 *   interface Person { firstName: string; lastName: string; }
 *   const personName1 = nameof<Person>("firstName"); // => "firstName"
 * @param name - string | number | symbol
 */
export const nameof = <T>(name: Extract<keyof T, string>): string => name;

export function capitalizeFirstLetter(string?: string) {
  return string ? string.charAt(0).toUpperCase() + string.slice(1) : '';
}

export function capitalizeFirstWordLetters(string?: string) {
  return string
    ? string
        .split(' ')
        .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ')
    : '';
}

/**
 * LogRunningFrom
 * Для отладки
 * @param from
 */
export function LogRunningFrom(from: string, data?: any) {
  console.log(
    `${process.server ? 'Server side::' : 'Client side::'}        ${from}       data:`,
    data,
  );
}

export function getSchemasIntersection(...schemas: ZodSchema[]) {
  let intersection = schemas.shift()!;
  while (schemas.length) {
    intersection = z.intersection(intersection, schemas.shift()!);
  }
  return intersection;
}
