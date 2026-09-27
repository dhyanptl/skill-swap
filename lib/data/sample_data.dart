import 'package:flutter/material.dart';

import '../models/skill.dart';
import '../models/student.dart';

const List<Skill> skills = [
  Skill(name: 'Flutter', icon: Icons.code_rounded),
  Skill(name: 'n8n Agentic Automation', icon: Icons.auto_awesome_rounded),
  Skill(name: 'Claude Ecosystem', icon: Icons.psychology_alt_outlined),
  Skill(name: 'JavaScript', icon: Icons.javascript),
  Skill(name: 'Web Development', icon: Icons.language_rounded),
  Skill(name: 'Photography', icon: Icons.camera_alt_outlined),
];

const List<Student> students = [
  Student(
    name: 'Rahul Sharma',
    level: 'Intermediate',
    canTeach: ['Flutter', 'JavaScript'],
    wantsToLearn: ['Claude Ecosystem', 'Web Development'],
  ),
  Student(
    name: 'Ananya Shah',
    level: 'Advanced',
    canTeach: ['Flutter', 'Claude Ecosystem'],
    wantsToLearn: ['JavaScript', 'n8n Agentic Automation'],
  ),
  Student(
    name: 'Karan Mehta',
    level: 'Intermediate',
    canTeach: ['Flutter', 'n8n Agentic Automation'],
    wantsToLearn: ['Web Development', 'Photography'],
  ),
  Student(
    name: 'Priya Desai',
    level: 'Advanced',
    canTeach: ['n8n Agentic Automation', 'Web Development'],
    wantsToLearn: ['Flutter', 'JavaScript'],
  ),
  Student(
    name: 'Arjun Patel',
    level: 'Intermediate',
    canTeach: ['JavaScript', 'Photography'],
    wantsToLearn: ['Flutter', 'Claude Ecosystem'],
  ),
  Student(
    name: 'Meera Joshi',
    level: 'Advanced',
    canTeach: ['Claude Ecosystem', 'JavaScript'],
    wantsToLearn: ['n8n Agentic Automation', 'Photography'],
  ),
  Student(
    name: 'Riya Kapoor',
    level: 'Intermediate',
    canTeach: ['Claude Ecosystem', 'Web Development'],
    wantsToLearn: ['Flutter', 'JavaScript'],
  ),
  Student(
    name: 'Aditya Shah',
    level: 'Advanced',
    canTeach: ['JavaScript', 'Web Development'],
    wantsToLearn: ['Flutter', 'Claude Ecosystem'],
  ),
  Student(
    name: 'Neha Patel',
    level: 'Beginner',
    canTeach: ['Flutter', 'Photography'],
    wantsToLearn: ['JavaScript', 'n8n Agentic Automation'],
  ),
];
