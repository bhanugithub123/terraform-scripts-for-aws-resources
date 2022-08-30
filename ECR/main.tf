resource "aws_ecr_repository" "terraform-repository" {
    name = "terraform-repo"
    image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository_policy" "terraform-repo-policy" {
    repository = aws_ecr_repository.terraform-repository.name
    policy     = <<EOF
    {
    "Version": "2008-10-17",
    "Statement": [
        {
        "Sid": "adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:CompleteLayerUpload",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetLifecyclePolicy",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
        ]
        }
    ]
    }
    EOF
}