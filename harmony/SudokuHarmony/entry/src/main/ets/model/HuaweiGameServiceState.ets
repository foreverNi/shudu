import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { gamePlayer } from '@kit.GameServiceKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const LOG_DOMAIN: number = 0x0000
const LOG_TAG: string = 'SudokuGameService'

class InitWaiter {
  resolve: () => void = () => {}
  reject: (error: BusinessError) => void = () => {}
}

export class HuaweiGameServiceState {
  private static initialized: boolean = false
  private static initializing: boolean = false
  private static initError: BusinessError | undefined = undefined
  private static waiters: InitWaiter[] = []

  static initializeFromAbility(context: common.UIAbilityContext): void {
    if (HuaweiGameServiceState.initialized || HuaweiGameServiceState.initializing) {
      return
    }
    HuaweiGameServiceState.initializing = true
    HuaweiGameServiceState.initError = undefined
    gamePlayer.init(context).then(() => {
      HuaweiGameServiceState.initialized = true
      HuaweiGameServiceState.initializing = false
      hilog.info(LOG_DOMAIN, LOG_TAG, 'Game Service initialized from EntryAbility.')
      HuaweiGameServiceState.resolveWaiters()
    }).catch((error: BusinessError) => {
      HuaweiGameServiceState.initialized = false
      HuaweiGameServiceState.initializing = false
      HuaweiGameServiceState.initError = error
      hilog.error(LOG_DOMAIN, LOG_TAG, 'Game Service init failed. code=%{public}d message=%{public}s',
        error.code, error.message)
      HuaweiGameServiceState.rejectWaiters(error)
    })
  }

  static waitInitialized(): Promise<void> {
    if (HuaweiGameServiceState.initialized) {
      return Promise.resolve()
    }
    if (HuaweiGameServiceState.initError) {
      return Promise.reject(HuaweiGameServiceState.initError)
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
