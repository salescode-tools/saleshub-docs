🌟 What Is stackable?

stackable is a boolean flag stored at the Promotion level that controls whether this promotion:

✔️ can combine with other promotions,
or
❌ must be applied alone (i.e., it is exclusive).

This field ensures that your engine behaves the same way as real FMCG trade schemes used by Unilever, P&G, CavinKare, Perfetti etc.

🎯 Why Does a Promotion Need stackable?

Because in real B2B e-commerce & distributor incentive schemes:

✔ Some promotions CAN be applied together

Example:

“Item Discount 10%”

“Free 1 unit if you buy 10”

Both should apply at the same time.

❌ Some promotions CANNOT be applied together

Example:

“Bill Buster 10% off”

“Mega Bill Buster 15% off”
Only ONE should apply → always the BEST one.

These are exclusive.

So stackable defines the combination behavior.

🔥 How Your Engine Uses stackable
🔹 Case 1: stackable = TRUE

Promotion is combinable with others in the same stack group.

Engine will apply all valid promotions in that group.

Example

Promotions:

P1 (stackable=true): 10% off

P2 (stackable=true): ₹50 off

Engine result:

Both P1 and P2 apply

Total item discount = (10% of gross) + 50

🔹 Case 2: stackable = FALSE (Exclusive Promotion)

Only one promotion from that group can apply —
the best one.

Engine will:

Collect all promotions in the group.

Compare their totalBenefit = discountAmount + freeGoodsValue.

Pick the single promotion with highest benefit.

Ignore the rest.

Example

Promotions:

P1 (stackable=false): 10% off

P2 (stackable=true): ₹50 off

BUT because P1 is exclusive, engine locks that entire group.

Suppose gross = 1000 →
P1 benefit = 100
P2 benefit = 50

Result → only P1 applies.

🧠 Internals: Group Logic (How stacking works per group)

Promotions belong to buckets internally called stack groups:

Promo Kind	Default Stack Group
ORDER_DISCOUNT	BILL_DISCOUNT
ITEM_DISCOUNT	ITEM_DISCOUNT
FREE_GOODS	FREE_GOODS
SLAB_SCHEME	SLAB

You can override these via extended_attr.stack.group, but these defaults work for 99% of B2B schemes.

Engine logic inside each group:
IF any promotion in group has stackable=false THEN
apply ONLY the best promotion in that group
ELSE
apply ALL promotions in the group (full stacking)
END

🔬 Step-by-Step Walkthrough (From Your Engine)
Example candidates for ITEM group:
Promo	stackable	Benefit
P1	true	80
P2	true	40
P3	false	120

Engine sees P3 is exclusive (stackable=false)
→ Entire ITEM group becomes exclusive

Then engine picks the best:

maxBenefit = 120 (P3)


Final applied:

ONLY P3

🧪 What Happens If NO Promo Is Exclusive?

Then engine applies all matching promos.

Example:

P1: stackable=true, 10% = 100 benefit

P2: stackable=true, 5% = 50 benefit

Engine applies BOTH:

Order discount = 150

🧩 Where Is stackable Used in Code?
In your engine: stackAndSelect()
boolean anyExclusive = group.stream().anyMatch(re -> !re.promotion.stackable);

if (anyExclusive) {
RuleEval best = group.stream()
.max(Comparator.comparing(RuleEval::totalBenefit))
.orElse(null);

    applied.add(toApplied(best, itemScope));
} else {
// Full stack
for (RuleEval re : group) {
applied.add(toApplied(re, itemScope));
}
}

🔥 Summary
stackable	Meaning	Behavior
TRUE	Promotion can combine with others	Apply ALL eligible promos in that stack group
FALSE	Promotion is exclusive	Apply ONLY this group’s BEST promo
✔ Real Use Cases
✔ FMCG: Bill Buster vs Mega Bill Buster

Only one should apply → exclusive → stackable=false

✔ FMCG: Item discount + free goods

Both apply → stackable → stackable=true

✔ Loyalty Points + Discount

Stackable → both apply

✔ Cashback vs Discount

Client dependent → use stackable to control