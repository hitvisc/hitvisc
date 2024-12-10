import dataSource from '../../../typeorm-config';

export const getSequenceNextValue = async (
  schemaName: string,
  sequenceName: string,
) => {
  const [{ nextval }] = await dataSource.manager.query(
    `select nextval from nextval('${schemaName}.${sequenceName}')`,
  );
  return nextval;
};
