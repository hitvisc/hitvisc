import * as util from 'util';

export interface IEnsureParamObject<T> {
  [key: string]: T;
}

export type EnsureCheck<T> = (paramObject: IEnsureParamObject<T>) => T;

export function getParamNameAndValue<T>(paramObject: { [key: string]: T }): {
  name: string;
  value: T;
} {
  const [paramKey, paramValue] = Object.entries(paramObject)[0];
  return { name: paramKey, value: paramValue as T };
}

function isDefined<T>(value: T) {
  return value !== null && value !== undefined;
}

export function notNull<T>(paramObject: { [key: string]: T }) {
  const { name, value } = getParamNameAndValue(paramObject);
  if (isDefined(value)) return value;

  throw new ArgumentError(`'${name}' can not be null or undefined`);
}

export function ensureNull<T>(paramObject: { [key: string]: T }) {
  const { name, value } = getParamNameAndValue(paramObject);
  if (!isDefined(value)) return value;

  throw new ArgumentError(`'${name}' must be null`);
}

export function ensureNumber(paramObject: { [key: string]: number }) {
  notNull(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);

  if (typeof value !== 'number')
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' of type '${typeof value}' is not a number, `,
    );

  return value;
}

export function ensureNotNegativeNumber(paramObject: { [key: string]: number }) {
  notNull(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);

  if (typeof value !== 'number')
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' of type '${typeof value}' is not a number, `,
    );
  if (!(value >= 0))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' of type '${typeof value}' is not a positive number`,
    );
  return value;
}

export function ensurePositiveNumber(paramObject: { [key: string]: number }) {
  ensureNotNegativeNumber(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);

  if (!(value > 0))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' of type '${typeof value}' is not a positive number`,
    );
  return value;
}

export function ensureInIntegerRange(
  paramObject: { [key: string]: number },
  range: { min: number; max: number },
) {
  const { name, value } = getParamNameAndValue(paramObject);

  if (!(Number.isInteger(range.min) && Number.isInteger(range.max))) {
    throw new ArgumentError('Invalid validation range, min and max values should be a integers');
  }

  if (!Number.isInteger(value)) {
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' of type '${typeof value}' is not a integer number`,
    );
  }

  if (!(range.min <= value && value <= range.max))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' is not in a range ${range.min}...${range.max}`,
    );
  return value;
}

export function getInIntegerRangeValidator(range: { min: number; max: number }) {
  return (paramObject: { [key: string]: number }) => ensureInIntegerRange(paramObject, range);
}

export function ensureInRange(
  paramObject: { [key: string]: number },
  range: { min: number; max: number },
) {
  ensureNumber(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);

  if (!(range.min <= value && value <= range.max))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' is not in a range ${range.min}...${range.max}`,
    );
  return value;
}

export function getInRangeValidator(range: { min: number; max: number }) {
  return (paramObject: { [key: string]: number }) => ensureInRange(paramObject, range);
}

export function ensureValidNumberRange(
  start: { [key: string]: number },
  end: { [key: string]: number },
) {
  ensureNumber(start);
  ensureNumber(end);

  const startParam = getParamNameAndValue(start);
  const endParam = getParamNameAndValue(end);

  if (endParam.value <= startParam.value)
    throw new ArgumentError(
      `'${endParam.name}' (${endParam.value}) must be greater or equal than '${startParam.name}' (${startParam.value})`,
    );
}

export function ensureMaxFileSizeBites(
  paramObject: { [key: string]: number },
  maxSizeBites: number,
  fileName: string,
) {
  ensurePositiveNumber(paramObject);
  ensureNotNegativeNumber({ maxSizeBites });

  const { name, value } = getParamNameAndValue(paramObject);

  if (value > maxSizeBites)
    throw new ArgumentError(
      `Invalid argument '${name}': uploaded file ${fileName} to big; size of file:${value}b; max size:${maxSizeBites}b`,
    );

  return value;
}

export function ensurePositiveInteger(paramObject: { [key: string]: number }) {
  ensurePositiveNumber(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);

  if (!Number.isInteger(value))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' is not an integer number`,
    );
  return value;
}

export function ensureNotNegativeInteger(paramObject: { [key: string]: number }) {
  ensureNumber(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);

  if (!Number.isInteger(value))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' is not an integer number`,
    );
  if (!(value >= 0))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' is not a positive number`,
    );
  return value;
}

function isEnumValueOfType(enumType: any, value: any) {
  return Object.values(enumType)?.includes(value);
}

export function ensureEnumValue(enumType: any, paramObject: { [key: string]: any }) {
  notNull(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);
  if (!isEnumValueOfType(enumType, value))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' is not a valid enum value`,
    );
  return value;
}

export function getEnumValidator(enumType: any) {
  return (paramObject: { [key: string]: number }) => ensureEnumValue(enumType, paramObject);
}

export function ensureObject(paramObject: { [key: string]: any }) {
  const { name, value } = getParamNameAndValue(paramObject);
  if (typeof value !== 'object' || Array.isArray(value))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' is not a valid object value`,
    );
  return value;
}

export function ensureString(paramObject: { [key: string]: string }) {
  const { name, value } = getParamNameAndValue(paramObject);

  if (typeof value === 'string') return value;

  throw new ArgumentError(`Invalid argument '${name}': value '${value}' is not a valid string`);
}

const digitRegex = /(\d+)$/i;
export function ensureDigitString(paramObject: { [key: string]: any }) {
  notNull(paramObject);
  ensureString(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);
  if (!digitRegex.test(value))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' is not a valid digit string`,
    );
  return value;
}

export function notNullOrEmptyString(paramObject: { [key: string]: string }) {
  const { name, value } = getParamNameAndValue(paramObject);

  notNull<string>(paramObject);

  if (typeof value === 'string' && value.trim() !== '') return value;

  throw new ArgumentError(
    `Invalid argument '${name}': value '${value}' is not a valid, not-empty string`,
  );
}

export function ensureStringLimit(maxLength: number, paramObject: IEnsureParamObject<string>) {
  ensurePositiveInteger({ maxLength });
  notNull(paramObject);
  ensureString(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);
  if (value.length > maxLength) {
    throw new ArgumentError(`Invalid argument '${name}': value '${value}' is not a valid string`);
  }

  return value;
}

export function ensureMinStringLength(minLength: number, paramObject: IEnsureParamObject<string>) {
  ensurePositiveInteger({ minLength });
  notNull(paramObject);
  ensureString(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);

  if (value.length < minLength) {
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' string length is lower than ${minLength} or not string`,
    );
  }

  return value;
}

export function getEnsureMinStringLength(minLength: number) {
  return (paramObject: { [key: string]: string }) => ensureMinStringLength(minLength, paramObject);
}

export function ensureValidMonth(paramObject: { [key: string]: number }) {
  ensurePositiveInteger(paramObject);

  const { name, value } = getParamNameAndValue(paramObject);

  if (value < 13) return value;

  throw new ArgumentError(`Invalid argument '${name}': value '${value}' is not a valid month`);
}

export function ensureValidDate(paramObject: { [key: string]: Date }) {
  notNull(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);
  if (value instanceof Date && value.getTime()) return value;

  throw new ArgumentError(`Invalid argument '${name}': value '${value}' is not a valid Date`);
}

export function ensureValidDateRange(
  startDateParamObject: { [key: string]: Date },
  endDateParamObject: { [key: string]: Date },
) {
  ensureValidDate(startDateParamObject);
  ensureValidDate(endDateParamObject);
  const startDate = getParamNameAndValue(startDateParamObject);
  const endDate = getParamNameAndValue(startDateParamObject);

  if (endDate.value < startDate.value)
    throw new ArgumentError(
      `'${endDate.name}' (${endDate.value}) must be greater or equal than '${startDate.name}' (${startDate.value})`,
    );
}

export function ensureValidBool(paramObject: { [key: string]: boolean }) {
  const { name, value } = getParamNameAndValue(paramObject);
  notNull(paramObject);
  if (typeof value === 'boolean') return value;

  throw new ArgumentError(`Invalid argument '${name}': value '${value}' is not a valid bool`);
}

const urlRegex = new RegExp(
  '^(https?:\\/\\/)?' + // protocol
    '((([a-zа-яё-\\d]([a-zа-яё-\\d-]*[a-zа-яё-\\d])*)\\.)+[a-zа-яё-]{2,}|' + // domain name
    '(localhost)|' + // OR localhost
    '((\\d{1,3}\\.){3}\\d{1,3}))' + // OR ip (v4) address
    '(\\:\\d+)?(\\/[-a-zа-яё-\\d%_.~+]*)*' + // port and path
    '(\\?[;&a-zа-яё-\\d%_.~+=-]*)?' + // query string
    '(\\#[-a-zа-яё-\\d_]*)?$',
  'i',
);

export function ensureValidUrl(paramObject: { [key: string]: any }) {
  notNull(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);
  if (!urlRegex.test(value))
    throw new ArgumentError(`Invalid argument '${name}': value '${value}' is not a valid url`);
  return value;
}

export function ensureValidRegExp(paramObject: { [key: string]: string }, regExp: RegExp) {
  const { name, value } = getParamNameAndValue(paramObject);
  if (!regExp.test(value))
    throw new ArgumentError(`Invalid argument '${name}': value '${value}' should be cyrillic only`);
  return value;
}

export function ensureCustom<T>(
  paramObject: { [key: string]: any },
  check: (value: T) => boolean,
  errorDetails: string,
) {
  notNull(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);
  if (!check(value))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${util.inspect(value, true, 0)}' is ${errorDetails}`,
    );
  return value;
}

export function getEnsureCustom<T>(check: (value: T) => boolean, errorMessage: string) {
  notNull({ check });
  notNullOrEmptyString({ errorMessage });
  return (paramObject: { [key: string]: T }) => ensureCustom<T>(paramObject, check, errorMessage);
}

export function getEnsureInstanceOf<T>(targetTypeConstructor: any) {
  notNull({ targetTypeConstructor });
  const constructor = targetTypeConstructor as unknown as new (...args: any[]) => T;
  return (paramObject: { [key: string]: T }) => ensureInstanceOf(constructor, paramObject);
}

export function ensureInstanceOf(targetTypeConstructor: any, paramObject: { [key: string]: any }) {
  const constructor = targetTypeConstructor as unknown as new (...args: any[]) => any;
  const { name, value } = getParamNameAndValue(paramObject);
  if (!(value instanceof targetTypeConstructor))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${value}' is not an instance of ${constructor.name}`,
    );
  return value;
}

export function ensureArray<T>(paramObject: IEnsureParamObject<ReadonlyArray<T>>) {
  notNull({ paramObject });
  const { name, value } = getParamNameAndValue(paramObject);
  if (!Array.isArray(value))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${util.inspect(value, true, 0)}' is not a valid array`,
    );

  return value;
}

export function ensureNonEmptyArray<T>(paramObject: IEnsureParamObject<ReadonlyArray<T>>) {
  notNull({ paramObject });
  const { name, value } = getParamNameAndValue(paramObject);
  if (!Array.isArray(value))
    throw new ArgumentError(
      `Invalid argument '${name}': value '${util.inspect(value, true, 0)}' is not a valid array`,
    );

  if (value.length <= 0)
    throw new ArgumentError(
      `Invalid argument '${name}': value '${util.inspect(value, true, 0)}' is empty array.`,
    );
  return value;
}

export function ensureArrayMaxLength<T>(
  maxLength: number,
  paramObject: IEnsureParamObject<ReadonlyArray<T>>,
) {
  ensureArray(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);

  if (value.length > maxLength)
    throw new ArgumentError(
      `Invalid argument '${name}': value '${util.inspect(
        value,
        true,
        0,
      )}' is сontains more than ${maxLength} elements.`,
    );

  return value;
}

export function ensureArrayMinLength<T>(
  minLength: number,
  paramObject: IEnsureParamObject<ReadonlyArray<T>>,
) {
  ensureNotNegativeNumber({ minLength });
  ensureArray(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);

  if (value.length < minLength)
    throw new ArgumentError(
      `Invalid argument '${name}': value '${util.inspect(
        value,
        true,
        0,
      )}' is сontains less than ${minLength} elements.`,
    );

  return value;
}

export function ensureArrayFixedLength<T>(length: number, paramObject: IEnsureParamObject<T[]>) {
  ensureNotNegativeNumber({ length });
  ensureArray(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);

  if (value.length !== length)
    throw new ArgumentError(
      `Invalid argument '${name}': value '${util.inspect(
        value,
        true,
        0,
      )}' is not сontains ${length} elements. Length of array: ${value.length}`,
    );

  return value;
}

export function ensureAll<T>(
  check: EnsureCheck<T>,
  paramObject: IEnsureParamObject<ReadonlyArray<T>>,
) {
  notNull({ check });
  ensureArray(paramObject);
  const { name, value } = getParamNameAndValue(paramObject);
  for (let i = 0; i < value.length; i++) {
    try {
      const checkParam = {};
      // @ts-ignore
      checkParam[`element at position ${i}`] = value[i];
      check(checkParam);
    } catch (e) {
      if (e instanceof ArgumentError) {
        throw new ArgumentError(`Array '${name}' validation error: ${e.message}`);
      }
      throw e;
    }
  }

  return value;
}

export function isNotRequired<T>(check: EnsureCheck<T>, paramObject: IEnsureParamObject<T>) {
  const { value } = getParamNameAndValue(paramObject);
  if (!isDefined(value)) {
    return value;
  }

  return check(paramObject);
}

const mailRegex =
  /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/i;

export function ensureValidEmail(paramObject: IEnsureParamObject<string>) {
  const { value } = getParamNameAndValue(paramObject);
  if (mailRegex.test(value)) return value;

  throw new ArgumentError(`Invalid argument email: '${value}' is not a valid email value`);
}

const nameRegex = /^[а-яёА-ЯЁ -]{2,50}$/i;

export function ensureValidName(paramObject: IEnsureParamObject<string>) {
  const { value } = getParamNameAndValue(paramObject);
  if (nameRegex.test(value)) return value;

  throw new ArgumentError(`Invalid argument: '${value}' is not a valid name value`);
}

export function ensureObjectId(paramObject: { [key: string]: string }) {
  const { name, value } = getParamNameAndValue(paramObject);
  if (value == null || !/^[a-fA-F0-9]{24}$/.test(value))
    throw new ArgumentError(`Invalid argument '${name}': value '${value}' is not a valid ObjectId`);
  return value;
}

const ogrnValidatorByType = new Map([
  [
    13,
    (ogrn: number[]) => {
      return ogrn.length === 13 && ogrn[12] === Math.floor((Number(ogrn.join('')) / 10) % 11) % 10;
    },
  ],
  [
    15,
    (ogrn: number[]) => {
      return ogrn.length === 15 && ogrn[14] === Math.floor((Number(ogrn.join('')) / 10) % 13) % 10;
    },
  ],
]);

export function ensureOgrn(paramObject: { [key: string]: string }) {
  const { name, value } = getParamNameAndValue(paramObject);
  notNull({ paramObject });
  ensureDigitString(paramObject);

  const validator = ogrnValidatorByType.get(value.length);
  if (!validator) {
    throw new ArgumentError(`Invalid argument '${name}': value '${value}' has wrong length`);
  }

  const preparedOgrn = [...value].map((char) => Number(char));

  if (!validator(preparedOgrn)) {
    throw new ArgumentError(`Invalid argument '${name}': value '${value}' has wrong checksum`);
  }
  return value;
}

class ArgumentError extends Error {
  constructor(message: string) {
    super(message);
  }

  static FromParam<T>(paramObject: { [key: string]: T }, errorDetails = '') {
    const param = getParamNameAndValue(paramObject);

    let message = `Невалидное значение параметра '${param.name}': '${param.value}'`;
    if (errorDetails) {
      message += ` - ${errorDetails}`;
    }

    return new ArgumentError(message);
  }
}
