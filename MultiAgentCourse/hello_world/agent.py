class Agent:

    wealth = 1

    def __init__(self, id):
        self.id = id

    def get_id(self):
        return self.id

    def set_position(self, x, y):
        self.x = x
        self.y = y

    def get_colour(self):
        if self.wealth == 0:
            return '#000000'
        elif self.wealth > 5:
            return '#00ff00'
        else:
            return '#ff0000'

    def get_position(self):
        return self.x, self.y