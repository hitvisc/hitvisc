export enum TypeOfUse {
  // neither item nor its description are visible to other users
  Restricted = 'R',

  // the item is not available to other users, the description is visible to other users
  Private = 'P',

  // the item is available to other users, the description is visible to other users
  Public = 'O',
}
