import { Redirect } from "expo-router";
import { useEffect, useState } from "react";
import { getToken } from "../services/api";

export default function Index() {
  const [checked, setChecked] = useState(false);
  const [hasToken, setHasToken] = useState(false);

  useEffect(() => {
    getToken().then((t) => {
      setHasToken(!!t);
      setChecked(true);
    });
  }, []);

  if (!checked) return null;
  return <Redirect href={hasToken ? "/(app)/" : "/(auth)/welcome"} />;
}
