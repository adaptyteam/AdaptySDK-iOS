* [`ProductModel`](#productmodel)
  + [`ProductDiscountModel`](#productdiscountmodel)
  + [`ProductSubscriptionPeriodModel`](#productsubscriptionperiodmodel)
* [`PurchaserInfoModel`](#purchaserinfomodel)
  + [`AccessLevelInfoModel`](#accesslevelinfomodel)
  + [`SubscriptionInfoModel`](#subscriptioninfomodel)
  + [`NonSubscriptionInfoModel`](#nonsubscriptioninfomodel)
* [`PaywallModel`](#paywallmodel)
* [`PromoModel`](#promomodel)

# Models

## `ProductModel`

This model contains information about the product.

| Name  | Description |
| -------- | ------------- |
| vendorProductId | Unique identifier of the product. |
| introductoryOfferEligibility | Eligibility of user for introductory offer. |
| promotionalOfferEligibility | Eligibility of user for promotional offer. |
| promotionalOfferId | Id of the offer, provided by Adapty for this specific user. |
| localizedDescription | A description of the product. |
| localizedTitle | The name of the product. |
| price | The cost of the product in the local currency. |
| currencyCode | Product locale currency code. |
| currencySymbol | Product locale currency symbol. |
| regionCode | Product locale region code. |
| subscriptionPeriod | A [`ProductSubscriptionPeriodModel`](#productsubscriptionperiodmodel) object. The period details for products that are subscriptions. |
| introductoryDiscount | A [`ProductDiscountModel`](#productdiscountmodel) object, containing introductory price information for the product. |
| discounts | An array of [`ProductDiscountModel`](#productdiscountmodel) discount offers available for the product. |
| subscriptionGroupIdentifier | The identifier of the subscription group to which the subscription belongs. |
| localizedPrice | Localized price of the product. |
| localizedSubscriptionPeriod | Localized subscription period of the product. |
| skProduct | [`SKProduct`](https://developer.apple.com/documentation/storekit/skproduct) assigned to this product. |

### `ProductDiscountModel`

| Name  | Description |
| -------- | ------------- |
| price | The discount price of the product in the local currency. |
| identifier | A string used to uniquely identify a discount offer for a product. |
| subscriptionPeriod | A [`ProductSubscriptionPeriodModel`](#productsubscriptionperiodmodel) object that defines the period for the product discount. |
| numberOfPeriods | An integer that indicates the number of periods the product discount is available. |
| paymentMode | The payment mode for this product discount. |
| localizedPrice | Localized price of the discount. |
| localizedSubscriptionPeriod | Localized subscription period of the discount. |
| localizedNumberOfPeriods | Localized number of periods of the discount. |

### `ProductSubscriptionPeriodModel`

| Name  | Description |
| -------- | ------------- |
| unit | The increment of time that a subscription period is specified in. |
| numberOfUnits | The number of units per subscription period. |

## `PurchaserInfoModel`

This model contains information about user and his payment status.

| Name  | Description |
| -------- | ------------- |
| customerUserId | Id of the user in your system. |
| accessLevels | Dictionary where the keys are paid access level identifiers configured by developer in Adapty dashboard. Values are [`AccessLevelInfoModel`](#accesslevelinfomodel) objects. Can be null if the customer has no access levels. |
| subscriptions | Dictionary where the keys are vendor product ids. Values are [`SubscriptionInfoModel`](#subscriptioninfomodel) objects. Can be null if the customer has no subscriptions. |
| nonSubscriptions | Dictionary where the keys are vendor product ids. Values are array[] of [`NonSubscriptionInfoModel`](#nonsubscriptioninfomodel) objects. Can be null if the customer has no purchases. |

### `AccessLevelInfoModel`

`AccessLevelInfoModel` stores info about current users access level.

| Name  | Description |
| -------- | ------------- |
| id | Paid Access Level identifier configured by developer in Adapty dashboard. |
| isActive | Boolean indicating whether the paid access level is active. |
| vendorProductId | Identifier of the product in vendor system (App Store/Google Play etc.) that unlocked this access level. |
| store | The store that unlocked this subscription, can be one of: **app_store**, **play_store** & **adapty**. |
| activatedAt | The ISO 8601 datetime when access level was activated (may be in the future). |
| renewedAt | The ISO 8601 datetime when access level was renewed. |
| expiresAt | The ISO 8601 datetime when access level will expire (may be in the past and may be null for lifetime access). |
| isLifetime | Boolean indicating whether the paid access level is active for lifetime (no expiration date). If set to true you shouldn't use **expires_at**. |
| activeIntroductoryOfferType | The type of active introductory offer. Possible values are: **free_trial**, **pay_as_you_go** & **pay_up_front**. If the value is not null it means that offer was applied during the current subscription period. |
| activePromotionalOfferType | The type of active promotional offer. Possible values are: **free_trial**, **pay_as_you_go** & **pay_up_front**. If the value is not null it means that offer was applied during the current subscription period. |
| willRenew | Boolean indicating whether auto renewable subscription is set to renew. |
| isInGracePeriod | Boolean indicating whether auto renewable subscription is in grace period. |
| unsubscribedAt | The ISO 8601 datetime when auto renewable subscription was cancelled. Subscription can still be active, it just means that auto renewal turned off. Will set to null if the user reactivates subscription. |
| billingIssueDetectedAt | The ISO 8601 datetime when billing issue was detected (vendor was not able to charge the card). Subscription can still be active. Will set to null if the charge was successful. |
| vendorTransactionId | Transaction id of the purchase that unlocked this access level. |
| vendorOriginalTransactionId | Original transaction id of the purchase that unlocked this access level. For auto-renewable subscription, this will be the id of the first transaction in the subscription. |
| startsAt | The ISO 8601 datetime when the access level has started (could be in the future). |
| cancellationReason | The reason why the subscription was cancelled. Possible values are: **voluntarily_cancelled**, **billing_error**, **refund**, **price_increase**, **product_was_not_available**, **unknown**. |
| isRefund | Whether the purchase was refunded. |

### `SubscriptionInfoModel`

`SubscriptionInfoModel` stores info about vendor subscription.

| Name  | Description |
| -------- | ------------- |
| isActive | Boolean indicating whether the subscription is active. |
| vendorProductId | Identifier of the product in vendor system (App Store/Google Play etc.). |
| store | Store where the product was purchased. Possible values are: **app_store**, **play_store** & **adapty**. |
| activatedAt | The ISO 8601 datetime when access level was activated (may be in the future). |
| renewedAt | The ISO 8601 datetime when access level was renewed. |
| expiresAt | The ISO 8601 datetime when access level will expire (may be in the past and may be null for lifetime access). |
| startsAt | The ISO 8601 datetime when access level stared. |
| isLifetime | Boolean indicating whether the subscription is active for lifetime (no expiration date). If set to true you shouldn't use **expires_at**. |
| activeIntroductoryOfferType | The type of active introductory offer. Possible values are: **free_trial**, **pay_as_you_go** & **pay_up_front**. If the value is not null it means that offer was applied during the current subscription period. |
| activePromotionalOfferType | The type of active promotional offer. Possible values are: **free_trial**, **pay_as_you_go** & **pay_up_front**. If the value is not null it means that offer was applied during the current subscription period. |
| willRenew | Boolean indicating whether auto renewable subscription is set to renew. |
| isInGracePeriod | Boolean indicating whether auto renewable subscription is in grace period. |
| unsubscribedAt | The ISO 8601 datetime when auto renewable subscription was cancelled. Subscription can still be active, it just means that auto renewal turned off. Will set to null if the user reactivates subscription. |
| billingIssueDetectedAt | The ISO 8601 datetime when billing issue was detected (vendor was not able to charge the card). Subscription can still be active. Will set to null if the charge was successful. |
| isSandbox | Boolean indicating whether the product was purchased in sandbox or production environment. |
| vendorTransactionId | Transaction id in vendor system. |
| vendorOriginalTransactionId | Original transaction id in vendor system. For auto renewable subscription this will be id of the first transaction in the subscription. |
| cancellationReason | The reason why the subscription was cancelled. Possible values are: **voluntarily_cancelled**, **billing_error**, **refund**, **price_increase**, **product_was_not_available**, **unknown**. |
| isRefund | Whether the purchase was refunded. |

### `NonSubscriptionInfoModel`

`NonSubscriptionInfoModel` stores info about purchases that are not subscriptions.

| Name  | Description |
| -------- | ------------- |
| purchaseId | Identifier of the purchase in Adapty. You can use it to ensure that you've already processed this purchase (for example tracking one time products). |
| vendorProductId | Identifier of the product in vendor system (App Store/Google Play etc.). |
| store | Store where the product was purchased. Possible values are: **app_store**, **play_store** & **adapty**. |
| purchasedAt | The ISO 8601 datetime when the product was purchased. |
| isOneTime | Boolean indicating whether the product should only be processed once. If true, the purchase will be returned by Adapty API one time only. |
| isSandbox | Boolean indicating whether the product was purchased in sandbox or production environment. |
| vendorTransactionId | Transaction id in vendor system. |
| vendorOriginalTransactionId | Original transaction id in vendor system. For auto renewable subscription this will be id of the first transaction in the subscription. |
| isRefund | Whether the purchase was refunded. |

## `PaywallModel`

This model contains info about paywall.

| Name  | Description |
| -------- | ------------- |
| developerId | Name of the paywall in dashboard. |
| variationId | Unique identifier of the paywall. |
| revision | Revision of the paywall. |
| isPromo | If this paywall is actually related to [`PromoModel`](#promomodel). |
| products | An array of [`ProductModel`](#productmodel) related to this paywall. |
| visualPaywall | HTML representation of the paywall. |
| customPayload | Dictionary of paywall's custom properties. |
| customPayloadString | String representation of paywall's custom properties. |
| abTestName | Name of the current test |
| name | Paywall name |

## `PromoModel`

This model contains information about available promotional (if so) offer for current user. 

| Name  | Description |
| -------- | ------------- |
| promoType | Type of the current promo. |
| variationId | Unique identifier of the promo. |
| expiresAt | The ISO 8601 datetime when current promo offer will expire. |
| paywall | A [`PaywallModel`](#paywallmodel) object, containing related purchse paywall. |
