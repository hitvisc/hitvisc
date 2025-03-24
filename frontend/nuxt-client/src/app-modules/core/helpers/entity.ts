import { EntityState } from '~/app-modules/core/enums/EntityState';

export function getEntityStateClass(state: EntityState) {
  switch (state) {
    case EntityState.Preparing:
      return 'bg-blue-lt';
    case EntityState.Ready:
      return 'bg-green-lt';
    case EntityState.Locked:
      return 'bg-red-lt';
    case EntityState.Archived:
      return 'bg-purple-lt';
    case EntityState.InUse:
      return 'bg-orange-lt';
    default:
      throw new Error('not supported');
  }
}
