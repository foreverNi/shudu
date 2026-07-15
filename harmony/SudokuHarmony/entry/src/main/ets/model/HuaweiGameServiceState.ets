import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const LOG_DOMAIN: number = 0x0000
const LOG_TAG: string = 'SudokuGameService'

class InitWaiter {
  resolve: () => void = () => {}
  reject: (error: BusinessError) => void = () => {}
}

export class HuaweiGameServiceState {
  private static initialized: boolean = false
  private static waiters: InitWaiter[] = []

  static notifyInitialized(): void {
    HuaweiGameServiceState.initialized = true
    hilog.info(LOG_DOMAIN, LOG_TAG, 'Game Service initialized from EntryAbility.')
    HuaweiGameServiceState.resolveWaiters()
  }

  static notifyInitFailed(error: BusinessError): void {
    hilog.error(LOG_DOMAIN, LOG_TAG, 'Game Service init failed. code=%{public}d message=%{public}s',
      error.code, error.message)
    HuaweiGameServiceState.rejectWaiters(error)
  }

  static waitInitialized(): Promise<void> {
    if (HuaweiGameServiceState.initialized) {
      return Promise.resolve()
    }
    return new Promise<void>((resolve: () => void, reject: (error: BusinessError) => void) => {
      const waiter = new InitWaiter()
      waiter.resolve = resolve
      waiter.reject = reject
      HuaweiGameServiceState.waiters.push(waiter)
    })
  }

  private static resolveWaiters(): void {
    const waiters = HuaweiGameServiceState.waiters.splice(0)
    waiters.forEach((waiter: InitWaiter) => {
      waiter.resolve()
    })
  }

  private static rejectWaiters(error: BusinessError): void {
    const waiters = HuaweiGameServiceState.waiters.splice(0)
    waiters.forEach((waiter: InitWaiter) => {
      waiter.reject(error)
    })
  }
}
