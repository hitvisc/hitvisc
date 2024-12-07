import '@abraham/reflection';
import { describe, it, expect } from 'vitest';
import { container, injectable } from 'tsyringe';

@injectable()
class Service {}

describe('IOC - Injectable', () => {
  it('should not be registered in IOC container', () => {
    // injectable Class decorator factory that allows the class' dependencies to be injected at runtime.
    // TSyringe relies on several decorators in order to collect metadata about classes to be instantiated.
    expect(container.isRegistered(Service, true)).eq(false);
  });

  it('should always return new instance', () => {
    const firstInstance = container.resolve(Service);
    const secondInstance = container.resolve(Service);

    expect(firstInstance).instanceOf(Service);
    expect(secondInstance).instanceOf(Service);

    expect(firstInstance === secondInstance).eq(false);
  });
});
