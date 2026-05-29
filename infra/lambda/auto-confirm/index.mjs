// Auto-confirm Cognito users on sign-up (Pre Sign-up Lambda Trigger)
export const handler = async (event) => {
  // Auto-confirm the user
  event.response.autoConfirmUser = true;
  
  // Auto-verify email if provided
  if (event.request.userAttributes.email) {
    event.response.autoVerifyEmail = true;
  }
  
  // Auto-verify phone if provided
  if (event.request.userAttributes.phone_number) {
    event.response.autoVerifyPhone = true;
  }
  
  return event;
};
