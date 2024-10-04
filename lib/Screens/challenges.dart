import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Challenge {
  final int id;
  final String title;
  final String description;
  final int goal;

  Challenge({required this.id, required this.title, required this.description, required this.goal});

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      goal: json['goal'],
    );
  }
}

class ChallengesScreen extends StatefulWidget {
  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> challenges = [];
  bool isLoading = true;
  int userId = 1; // Temporary hardcoded user ID for demonstration purposes.

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    final url = Uri.parse('http://172.20.10.4:8000/api/challenges');
    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> challengeJson = json.decode(response.body);
        setState(() {
          challenges = challengeJson.map((json) => Challenge.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print('Failed to load challenges: ${response.body}');
        throw Exception('Failed to load challenges');
      }
    } catch (error) {
      print('Failed to fetch challenges: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _joinChallenge(int challengeId, int userId) async {
    final url = Uri.parse('http://172.20.10.4:8000/api/challenges/$challengeId/join');

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'user_id': userId, // Send user_id in JSON format
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('Joined challenge successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined challenge successfully')),
        );
      } else {
        print('Failed to join challenge: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join challenge: ${response.body}')),
        );
      }
    } catch (error) {
      print('Error joining challenge: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining challenge: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : challenges.isEmpty
          ? Center(child: Text('No challenges found'))
          : ListView.builder(
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return ListTile(
            title: Text(challenge.title),
            subtitle: Text(challenge.description),
            trailing: ElevatedButton(
              onPressed: () => _joinChallenge(challenge.id, userId),
              child: Text('Join'),
            ),
          );
        },
      ),
    );
  }
}
