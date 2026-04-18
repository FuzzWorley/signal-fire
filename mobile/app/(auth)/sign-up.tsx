import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
} from "react-native";
import { router } from "expo-router";
import { SafeAreaView } from "react-native-safe-area-context";
import * as WebBrowser from "expo-web-browser";
import * as AuthSession from "expo-auth-session";
import { Colors } from "../../constants/colors";
import { FontFamily, FontSize } from "../../constants/typography";
import { useAuth } from "../../hooks/useAuth";

WebBrowser.maybeCompleteAuthSession();

export default function SignUpScreen() {
  const [mode, setMode] = useState<"signup" | "signin">("signup");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const { signUp, signIn } = useAuth();

  async function handleSubmit() {
    if (!email || !password) {
      Alert.alert("Missing fields", "Please enter your email and password.");
      return;
    }
    setLoading(true);
    try {
      if (mode === "signup") {
        await signUp(email, password);
      } else {
        await signIn(email, password);
      }
    } catch (e: any) {
      const msg = e?.body?.error ?? "Something went wrong. Please try again.";
      Alert.alert("Error", msg);
    } finally {
      setLoading(false);
    }
  }

  function handleApple() {
    Alert.alert("Coming soon", "Apple Sign In is coming soon.");
  }

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : "height"}
        style={styles.keyboardView}
      >
        <ScrollView
          contentContainerStyle={styles.scroll}
          keyboardShouldPersistTaps="handled"
        >
          <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
            <Text style={styles.backText}>‹ Back</Text>
          </TouchableOpacity>

          <Text style={styles.eyebrow}>
            {mode === "signup" ? "CREATE ACCOUNT" : "SIGN IN"}
          </Text>
          <Text style={styles.headline}>Come in.</Text>
          <Text style={styles.subhead}>
            {mode === "signup" ? "Sign up or sign in." : "Welcome back."}
          </Text>

          <View style={styles.form}>
            <Text style={styles.label}>Email</Text>
            <TextInput
              style={styles.input}
              value={email}
              onChangeText={setEmail}
              placeholder="you@email.com"
              placeholderTextColor={Colors.muted}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
              accessibilityLabel="Email"
            />

            <Text style={styles.label}>Password</Text>
            <TextInput
              style={styles.input}
              value={password}
              onChangeText={setPassword}
              placeholder="········"
              placeholderTextColor={Colors.muted}
              secureTextEntry
              accessibilityLabel="Password"
            />

            <TouchableOpacity
              style={styles.primaryButton}
              onPress={handleSubmit}
              disabled={loading}
              activeOpacity={0.85}
            >
              <Text style={styles.primaryButtonText}>
                {loading
                  ? "Please wait…"
                  : mode === "signup"
                  ? "Create account"
                  : "Sign in"}
              </Text>
            </TouchableOpacity>
          </View>

          <View style={styles.divider}>
            <View style={styles.dividerLine} />
            <Text style={styles.dividerText}>or</Text>
            <View style={styles.dividerLine} />
          </View>

          <TouchableOpacity style={styles.socialButton} activeOpacity={0.85}>
            <Text style={styles.socialButtonText}>Continue with Google</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.socialButton, styles.appleButton]}
            onPress={handleApple}
            activeOpacity={0.85}
          >
            <Text style={[styles.socialButtonText, styles.appleButtonText]}>
              Continue with Apple
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.switchMode}
            onPress={() => setMode(mode === "signup" ? "signin" : "signup")}
          >
            <Text style={styles.switchModeText}>
              {mode === "signup" ? (
                <>Already have an account? <Text style={styles.switchModeLink}>Sign in</Text></>
              ) : (
                <>No account? <Text style={styles.switchModeLink}>Create one</Text></>
              )}
            </Text>
          </TouchableOpacity>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.paper },
  keyboardView: { flex: 1 },
  scroll: { paddingHorizontal: 28, paddingBottom: 40 },
  backButton: { paddingVertical: 12 },
  backText: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.base,
    color: Colors.stone,
  },
  eyebrow: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.stone,
    letterSpacing: 1,
    marginTop: 8,
    marginBottom: 6,
  },
  headline: {
    fontFamily: FontFamily.serifDisplay,
    fontSize: FontSize.display,
    color: Colors.ink,
    marginBottom: 4,
  },
  subhead: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.base,
    color: Colors.stone,
    marginBottom: 28,
  },
  form: { gap: 8 },
  label: {
    fontFamily: FontFamily.sansMedium,
    fontSize: FontSize.sm,
    color: Colors.ink,
    marginBottom: 4,
    marginTop: 8,
  },
  input: {
    backgroundColor: Colors.white,
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: 8,
    paddingHorizontal: 14,
    paddingVertical: 13,
    fontFamily: FontFamily.sans,
    fontSize: FontSize.base,
    color: Colors.ink,
  },
  primaryButton: {
    backgroundColor: Colors.ember,
    borderRadius: 10,
    paddingVertical: 16,
    alignItems: "center",
    marginTop: 8,
  },
  primaryButtonText: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.white,
  },
  divider: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 20,
    gap: 10,
  },
  dividerLine: { flex: 1, height: 1, backgroundColor: Colors.border },
  dividerText: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
  socialButton: {
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: 10,
    paddingVertical: 14,
    alignItems: "center",
    marginBottom: 10,
    backgroundColor: Colors.white,
  },
  socialButtonText: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.ink,
  },
  appleButton: {
    backgroundColor: Colors.ink,
    borderColor: Colors.ink,
  },
  appleButtonText: {
    color: Colors.white,
  },
  switchMode: { paddingTop: 16, alignItems: "center" },
  switchModeText: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
  switchModeLink: {
    color: Colors.ember,
    fontFamily: FontFamily.sansMedium,
  },
});
