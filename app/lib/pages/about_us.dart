import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset("assets/circle.png", height: 150)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "About Us",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Our mission is to deliver outstanding solutions with research and innovation. We believe in building long-term relationships with our clients by exceeding expectations and a great level of transparency.",
                  style: TextStyle(fontSize: 15),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Our Vision",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "To be recognized as a leading provider of quality software solutions worldwide.",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Our Team",
                  style: TextStyle(fontSize: 18),
                ),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  children: <Widget>[
                    _buildTeamMember('Jayalath Harshana', 'ID: 10898589',
                        'assets/profiles/10898589.jpeg'),
                    _buildTeamMember('Ekanayake Bandara', 'ID: 10899241',
                        'assets/profiles/10899241.jpeg'),
                    _buildTeamMember('Subasinghe RAVD', 'ID: 10900316',
                        'assets/profiles/10900316.jpeg'),
                    _buildTeamMember('Chamath Rathnayaka', 'ID: 10898681',
                        'assets/profiles/10898681.jpeg'),
                    _buildTeamMember('Wannaku Premawardana', 'ID: 10898673',
                        'assets/profiles/10898673.jpeg'),
                    _buildTeamMember('Dissanayaka Ranaweera', 'ID: 10898889',
                        'assets/profiles/10898889.jpeg'),
                    // Add more team members as needed
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    ));
  }

  Widget _buildTeamMember(String name, String id, String imagePath) {
    return Card(
      color: const Color.fromARGB(255, 248, 247, 247),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: AssetImage(imagePath),
              radius: 40.0,
            ),
            const SizedBox(height: 10.0),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              id,
              style: const TextStyle(
                fontSize: 14.0,
                color: Color.fromARGB(255, 107, 107, 107),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
