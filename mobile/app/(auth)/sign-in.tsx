import { Redirect } from "expo-router";

// sign-in is handled by the sign-up screen's mode toggle
export default function SignIn() {
  return <Redirect href="/(auth)/sign-up" />;
}
