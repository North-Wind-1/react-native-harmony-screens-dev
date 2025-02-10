import type { RNPackageContext, RNOHPackage, RNPackage } from '@rnoh/react-native-openharmony';
import { createRNOHPackages as createRNOHPackagesAutolinking } from "./RNOHPackagesFactory"
import RNOHScreensPackage from "@rnoh/react-native-openharmony-screens"

// export function getRNOHPackages(ctx: RNPackageContext): RNOHPackage[] {
export function getRNOHPackages(ctx: RNPackageContext): RNPackage[] {
  return [
    ...createRNOHPackagesAutolinking(ctx),
    new RNOHScreensPackage(ctx), // comment this line out when testing SamplePackage autolinking
  ]
}