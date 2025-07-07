# Story Generation Prompt Specification

## Overview
This document specifies the requirements for the AI story generation prompt to create engaging, pedagogically effective stories for language learners.

## Core Requirements

### 1. 避免套路化剧情 (Avoid Clichéd Plots)
- Reject common tropes like "it was all a dream", "love at first sight", or "the chosen one"
- Create unique scenarios and unexpected plot developments
- Vary story settings, time periods, and character types
- Mix genres: slice-of-life, mystery, sci-fi, fantasy, workplace drama, etc.

### 2. 避免干巴巴的剧情 (Avoid Dry/Boring Narratives)
- Include sensory details (sounds, smells, textures, visual descriptions)
- Add emotional depth and character interactions
- Use dialogue to make stories feel alive
- Include small conflicts or challenges that characters must overcome
- Show character emotions and reactions, not just actions

### 3. 强调故事角色的动机与语气的合理性 (Emphasize Character Motivation & Reasonable Tone)
- Every character action should have clear motivation
- Dialogue should match the character's personality, age, and background
- Emotional responses should be proportionate to events
- Avoid unrealistic or overly dramatic reactions
- Characters should speak and act consistently throughout the story

### 4. 避免用难词 (Avoid Difficult Words)
- Primary vocabulary should be appropriate for the learner's level
- If complex words are necessary for the story, provide native language explanations in parentheses
- Format: `complex_word (母语解释: meaning in native language)`
- Example: `The architect (建筑师: person who designs buildings) drew the blueprints.`

### 5. 允许不完美或开放性结局 (Allow Imperfect or Open Endings)
- Stories don't need to resolve all conflicts
- Characters can make mistakes and learn from them
- Some questions can remain unanswered
- Realistic outcomes are preferred over fairy-tale endings
- Bittersweet or ambiguous endings are acceptable

### 6. 处理混合语言词汇 (Handle Mixed Language Vocabulary)
When the provided word list contains words not in the learning language:
- **Identify**: Detect which words are not in the target learning language
- **Incorporate Strategically**: Use non-target language words as:
  - Proper nouns (names, places, brands)
  - Cultural references or foreign terms
  - Words a character is learning or translating
- **Contextual Integration**: Make the inclusion feel natural within the story
- **Educational Value**: Use these moments to teach language mixing in real-world contexts

## Story Structure Requirements

### Opening (开头)
- Start in the middle of action or an interesting moment
- Establish setting and main character quickly
- Create immediate engagement without excessive exposition

### Development (发展)
- Include 2-3 target vocabulary words naturally in each paragraph
- Show character growth or change
- Build tension or interest through small conflicts
- Use dialogue to reveal character and advance plot

### Conclusion (结尾)
- Resolve the immediate story tension
- Allow for character reflection or learning
- Can be open-ended or lead to new questions
- Avoid moralizing or heavy-handed lessons

## Post-Story Requirements

After each story, provide:

### Vocabulary Analysis
For each target vocabulary word used:

```
**Target Vocabulary Used:**

1. **[Word]** - [Sentence where it appeared]
   - 意思: [Meaning in user's native language]
   - 语境: [Context explanation if needed]

2. **[Word]** - [Sentence where it appeared]
   - 意思: [Meaning in user's native language]
   - 语境: [Context explanation if needed]
```

### Example:
```
**Target Vocabulary Used:**

1. **architect** - "The architect drew careful plans for the new library."
   - 意思: 建筑师 (设计建筑物的专业人士)

2. **blueprints** - "She studied the blueprints late into the night."
   - 意思: 蓝图, 设计图纸

3. **foundation** - "Workers began digging the foundation the next morning."
   - 意思: 地基, 基础
```

## Quality Indicators

### Good Story Elements:
- Natural vocabulary integration
- Realistic character behavior
- Sensory details and emotions
- Appropriate difficulty level
- Cultural authenticity
- Engaging plot progression

### Avoid:
- Forced vocabulary usage
- Unrealistic dialogue
- Overly complex sentence structures
- Cultural stereotypes
- Predictable outcomes
- Excessive exposition

## Language-Specific Considerations

### For English Learners:
- Use contractions and informal speech in dialogue
- Include idioms and phrasal verbs naturally
- Show various registers (formal/informal)

### For Chinese Learners:
- Include appropriate measure words (量词)
- Show formal/informal address patterns
- Use culturally appropriate contexts

### General:
- Adapt complexity to user's proficiency level
- Include cultural context naturally
- Make vocabulary memorable through emotional connection

## Technical Implementation Notes

The AI should:
1. Receive user's learning language and native language
2. Receive vocabulary word list with language identification
3. Generate story following above specifications
4. Provide post-story vocabulary analysis
5. Ensure appropriate content length (300-600 words optimal)

This specification should be implemented as the system prompt for the story generation AI service.