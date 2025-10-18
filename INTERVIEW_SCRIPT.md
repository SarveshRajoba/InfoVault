# InfoVault - Interview Preparation Script

## 🎯 **30-Second Elevator Pitch**
"InfoVault is a collaborative knowledge management platform built with Rails 8.0 that helps users organize study materials hierarchically and automatically generates practice questions using AI. It features user authentication, real-time collaboration, and integrates with Google's Gemini AI to create interactive learning experiences."

## 🏗️ **Technical Architecture**

### **Tech Stack:**
- **Backend:** Ruby on Rails 8.0.1
- **Database:** PostgreSQL
- **Frontend:** Hotwire (Turbo + Stimulus)
- **Authentication:** JWT + bcrypt
- **AI Integration:** Google Gemini API
- **Deployment:** Docker + Kamal
- **Testing:** RSpec + Capybara

### **Key Gems:**
- `gemini-ai` - AI question generation
- `jwt` - Token-based authentication
- `bcrypt` - Password hashing
- `httparty` - HTTP client for API calls
- `pry` - Debugging

## 📊 **Database Schema**

### **Core Models:**
1. **User** - Authentication and ownership
2. **Subject** - Top-level content organization
3. **Chapter** - Subject subdivisions
4. **Paragraph** - Actual content with AI-generated Q&A
5. **Question** - AI-generated practice questions
6. **Answer** - Corresponding answers
7. **Collaboration** - Multi-user access control

### **Relationships:**
```
User → Subjects → Chapters → Paragraphs → Questions → Answers
User ← Collaborations → Subjects (for sharing)
```

## 🔐 **Authentication System**

### **Implementation:**
- JWT tokens stored in HTTP-only cookies
- 24-hour session expiration
- bcrypt for password hashing
- Role-based access control (user/admin)

### **Security Features:**
- HTTP-only cookies prevent XSS
- Password validation (minimum 5 characters)
- Email format validation
- CSRF protection (except for auth endpoints)

## 🤖 **AI Integration**

### **Gemini Service:**
- Generates 5 Q&A pairs per paragraph
- Structured prompt engineering
- Error handling and logging
- Rate limiting considerations

### **AI Features:**
- Questions: 10-13 words max
- Answers: 20-30 words max
- Content sanitization for safety
- Fallback handling for API failures

## 👥 **Collaboration System**

### **Features:**
- Subject-level sharing
- Access level control
- Collaboration status tracking
- Owner vs collaborator permissions

### **Implementation:**
- Many-to-many relationship through collaborations table
- Status tracking (pending, accepted, rejected)
- Access levels (read, write, admin)

## 🎨 **Frontend Architecture**

### **Modern Rails Approach:**
- Hotwire for SPA-like experience
- Stimulus for JavaScript interactions
- Turbo for navigation and form handling
- Propshaft for asset pipeline

### **User Experience:**
- Responsive design
- Real-time updates
- Progressive enhancement
- No heavy JavaScript frameworks

## 🧪 **Testing Strategy**

### **Test Stack:**
- RSpec for unit and integration tests
- Capybara for system tests
- Factory Bot for test data
- Faker for realistic test data
- SimpleCov for coverage

### **Test Coverage:**
- Model validations and relationships
- Controller actions and authorization
- Service layer functionality
- API integrations

## 🚀 **Deployment & DevOps**

### **Infrastructure:**
- Docker containerization
- Kamal for deployment
- PostgreSQL in production
- Environment variable management

### **Security:**
- Brakeman for vulnerability scanning
- Environment-based configuration
- Secure cookie handling
- API key management

## 💡 **Key Technical Decisions**

### **Why Rails 8.0?**
- Latest features and security updates
- Modern asset pipeline (Propshaft)
- Improved performance
- Better developer experience

### **Why Hotwire over React/Vue?**
- Simpler development
- Better SEO
- Progressive enhancement
- Rails-native approach

### **Why PostgreSQL?**
- ACID compliance
- Complex relationships
- JSON support for future features
- Production-ready scalability

## 🎯 **Business Value**

### **Target Users:**
- Students and educators
- Research teams
- Content creators
- Study groups

### **Value Proposition:**
- Organized knowledge management
- AI-powered learning enhancement
- Collaborative study environments
- Automated practice question generation

## 🔮 **Future Enhancements**

### **Potential Features:**
- Real-time collaborative editing
- Advanced AI features (summarization, translation)
- Mobile app development
- Analytics and progress tracking
- Integration with LMS platforms

## 📈 **Performance Considerations**

### **Optimizations:**
- Database indexing on foreign keys
- N+1 query prevention
- Asset compression and caching
- API rate limiting
- Background job processing

## 🛡️ **Security Measures**

### **Implemented:**
- JWT token security
- Password hashing
- Input sanitization
- CSRF protection
- SQL injection prevention

### **Best Practices:**
- Environment variable usage
- Secure cookie configuration
- API key management
- Regular security updates

## 📝 **Code Quality**

### **Standards:**
- RuboCop for code style
- Consistent naming conventions
- Comprehensive documentation
- Modular service architecture
- Separation of concerns

---

## 🎤 **Common Interview Questions & Answers**

### **Q: Why did you choose Rails for this project?**
**A:** "Rails provides rapid development capabilities with built-in conventions that reduce decision fatigue. For a knowledge management platform, Rails' ActiveRecord makes complex relationships manageable, while Hotwire enables modern UX without the complexity of separate frontend frameworks."

### **Q: How do you handle the AI integration?**
**A:** "I created a dedicated GeminiService that encapsulates all AI interactions. It includes proper error handling, logging, and fallback mechanisms. The service is designed to be easily testable and maintainable, with clear separation of concerns."

### **Q: What's the most challenging part of this project?**
**A:** "Implementing the collaboration system while maintaining data integrity and security. Managing user permissions across the hierarchical content structure required careful consideration of the database relationships and authorization logic."

### **Q: How would you scale this application?**
**A:** "I'd implement caching strategies, background job processing for AI calls, database read replicas, and consider microservices for the AI integration. The current architecture with service objects makes it easier to extract services later."

### **Q: What would you do differently?**
**A:** "I'd add more comprehensive error handling for the AI service, implement real-time features with Action Cable, and add more sophisticated caching strategies. I'd also consider adding API versioning for future mobile app development."
