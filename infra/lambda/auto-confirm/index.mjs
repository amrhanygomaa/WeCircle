// Pre Sign-up Lambda Trigger — auto-confirms registration but does NOT
// auto-verify email. Cognito will send a real verification email; the
// email_verified claim in the id-token only becomes true after the user
// clicks the link. This prevents account-takeover via unverified email
// registration against an existing admin address.
export const handler = async (event) => {
  event.response.autoConfirmUser = true;
  // email_verified and phone_number_verified intentionally NOT set here.
  return event;
};
