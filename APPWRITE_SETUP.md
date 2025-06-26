# Appwrite Database Setup Guide

## Database Configuration

You need to create the following collections in your Appwrite database:

### Database ID
- Use the existing database ID: `685c69ca0000f9d61a7a`

### 1. Users Collection

**Collection ID**: `users`

**Attributes**:
- `name` (String, Required) - User's full name
- `email` (String, Required) - User's email address
- `lastSeen` (String, Optional) - ISO date string of last activity
- `avatarUrl` (String, Optional) - URL to user's profile picture (you can add this later if needed)

**Note**: The system automatically creates `$createdAt` and `$updatedAt` fields, so we don't need custom `createdAt` fields.

**Indexes**:
- Create index on `email` for faster lookups
- Create index on `createdAt` for ordering

**Permissions**:
- Read: Any authenticated user
- Write: Document owner only

### 2. Messages Collection

**Collection ID**: `messages`

**Attributes**:
- `senderId` (String, Required) - ID of message sender
- `receiverId` (String, Required) - ID of message receiver
- `content` (String, Required) - Message text content
- `conversationId` (String, Required) - ID of conversation this message belongs to
- `isRead` (Boolean, Optional) - Whether message has been read
- `createdAt` (String, Required) - ISO date string when message was sent

**Indexes**:
- Create compound index on `senderId` and `receiverId`
- Create index on `conversationId`
- Create index on `createdAt` for ordering

**Permissions**:
- Read: Participants of the conversation only
- Write: Authenticated users (sender verification happens in app logic)

### 3. Conversations Collection

**Collection ID**: `conversations`

**Attributes**:
- `participants` (String Array, Required) - Array of user IDs in conversation
- `lastMessage` (String, Optional) - Preview of the most recent message
- `lastMessageTime` (String, Required) - ISO date string of last message
- `createdAt` (String, Required) - ISO date string when conversation was created

**Indexes**:
- Create index on `participants` array
- Create index on `lastMessageTime` for ordering

**Permissions**:
- Read: Participants only
- Write: Participants only

## Storage Bucket Configuration

### Profile Pictures Bucket

**Bucket ID**: `profile-pics`

**Settings**:
- File Security: Enabled
- Maximum File Size: 5MB
- Allowed File Extensions: jpg, jpeg, png, webp
- Encryption: Enabled
- Antivirus: Enabled

**Permissions**:
- Read: Any authenticated user (for viewing profile pictures)
- Write: Authenticated users (for uploading their own pictures)

## Setup Steps

1. **Go to your Appwrite Console**
2. **Navigate to Databases** → Your existing database
3. **Create the three collections** with the specifications above
4. **Set up proper permissions** for each collection
5. **Create the storage bucket** for profile pictures
6. **Test the setup** by registering a new user in your app

## Security Rules

The app implements these security measures:

- Users can only update their own profile information
- Message permissions are enforced at the app level
- Real-time subscriptions filter messages by conversation participants
- Profile pictures are stored securely with user-based access control

## Testing Your Setup

After setting up the database:

1. **Register a new user** - This should create a document in the `users` collection
2. **Navigate to Messages** - Should show other registered users
3. **Start a conversation** - Should create a conversation document
4. **Send messages** - Should create message documents and update conversation

## Troubleshooting

**Common Issues**:
- **"invalid document 'avatarurl'" error**: This means the `avatarUrl` attribute doesn't exist in your users collection. See the solution below.
- **Permission errors**: Check that your collection permissions allow read/write for authenticated users
- **Index errors**: Ensure you've created indexes on frequently queried fields
- **Document creation fails**: Verify all required attributes are defined in your collections
- **Real-time not working**: Check that your real-time subscription channels match your database/collection IDs

### Fixing the "invalid document 'avatarurl'" Error

If you get this error, it means the `avatarUrl` attribute is missing from your users collection:

1. **Go to your Appwrite Console**
2. **Navigate to Databases** → Your database → **users collection**
3. **Go to the Attributes tab**
4. **Add a new attribute**:
   - Key: `avatarUrl`
   - Type: String
   - Size: 255 (or higher)
   - Required: No (uncheck this)
   - Array: No
   - Default: Leave empty

**Alternative Solution**: If you don't want to add the avatarUrl attribute, you can skip it entirely. The updated code now handles missing avatar URLs gracefully.

**Debug Tips**:
- Check the Appwrite console logs for detailed error messages
- Use the database section in Appwrite console to manually verify document creation
- Test API calls using the Appwrite REST API documentation

## Real-time Features

The app uses Appwrite's real-time capabilities to:
- Instantly show new messages in conversations
- Update online status of users
- Sync conversation lists across devices

Make sure real-time is enabled in your Appwrite project settings.
