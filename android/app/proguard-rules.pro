-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-keep @interface proguard.annotation.Keep
-keep @interface proguard.annotation.KeepClassMembers

# Razorpay-specific rules
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }
-dontwarn com.razorpay.**
