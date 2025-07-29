# UstreamBot Deployment Guide

## Backend Deployment Options

### Option 1: Google Cloud Functions (Recommended)

1. **Setup Google Cloud Project**
   \`\`\`bash
   gcloud config set project YOUR_PROJECT_ID
   gcloud auth login
   \`\`\`

2. **Deploy Function**
   \`\`\`bash
   cd backend
   npm install
   gcloud functions deploy chatbot --runtime nodejs18 --trigger-http --allow-unauthenticated
   \`\`\`

3. **Get Function URL**
   \`\`\`bash
   gcloud functions describe chatbot --format="value(httpsTrigger.url)"
   \`\`\`

### Option 2: Docker Deployment

1. **Build and Run Locally**
   \`\`\`bash
   cd backend
   docker-compose up --build
   \`\`\`

2. **Deploy to Cloud Run**
   \`\`\`bash
   gcloud run deploy ustreambot-backend --source . --platform managed --region us-central1 --allow-unauthenticated
   \`\`\`

## iOS App Configuration

1. **Update API Endpoint**
   - Open `UstreamBot-iOS/APIClient.swift`
   - Replace `baseURL` with your deployed function URL

2. **Test Connection**
   - Build and run the iOS app
   - Send a test message to verify backend connectivity

## ML Model Integration

1. **Train Custom Model**
   \`\`\`bash
   cd ml-training
   pip install -r requirements.txt
   python chatbot_setup.py
   \`\`\`

2. **Deploy Model to Backend**
   - Upload trained model to Google Cloud Storage
   - Update backend to load and use the custom model

## Environment Variables

Set these in your deployment environment:

- `NODE_ENV`: production
- `GCP_PROJECT_ID`: Your Google Cloud project ID
- `MODEL_PATH`: Path to your trained model (if using custom model)

## Monitoring and Logs

- **Google Cloud Functions**: View logs in Google Cloud Console
- **Docker**: Use `docker logs` command
- **iOS App**: Check Xcode console for API errors

## Security Considerations

1. **API Authentication**: Add API keys for production
2. **CORS Configuration**: Restrict origins in production
3. **Rate Limiting**: Implement request rate limiting
4. **Input Validation**: Sanitize all user inputs

