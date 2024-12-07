import '@abraham/reflection';
import { describe, it, expect } from 'vitest';
import { container, singleton } from 'tsyringe';

@singleton()
class Service {}

describe('IOC - Singletons', () => {
  it('should be registered in IOC container', () => {
    expect(container.isRegistered(Service)).eq(true);
  });

  it('should always return the same instance', () => {
    const firstLink = container.resolve(Service);
    const secondLink = container.resolve(Service);

    expect(firstLink === secondLink).eq(true);
  });
});
