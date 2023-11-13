let
  agenix-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLlb6OWE61LWlWU8pxNtfj40pzN+dqLVUXFdKYajpHA guif@glap";
in
{
  "signing-key.age".publicKeys = [ "${agenix-key}" ];
}
